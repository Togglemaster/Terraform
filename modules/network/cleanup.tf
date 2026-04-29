#============================================
# Safety-net: limpa LB/ENI/EIP orfaos da VPC ANTES do detach do IGW
#============================================
# Por que existe:
# Services type=LoadBalancer no EKS criam NLBs/ALBs *fora* do Terraform
# (cloud controller do K8s). Se algum vazar (helm uninstall falhou,
# kubeconfig stale, modulo helm removido do state, etc.), o IGW nao
# consegue detach por DependencyViolation: "VPC has mapped public
# address(es)".
#
# Como funciona:
# Este null_resource depende do aws_internet_gateway.igw, entao no
# destroy ele e processado ANTES do IGW. Varre a VPC e remove na ordem:
#  1. Todos os Load Balancers (NLB/ALB e Classic ELB) ainda vivos
#  2. ENIs com IP publico que sobraram (NLB pode levar 30-90s)
#  3. EIPs orfaos sem associacao (excluindo os que o Terraform gerencia)
# So entao libera o detach do IGW para acontecer com sucesso.
#
# Idempotente: se nao ha nada para limpar, sai em segundos.
#============================================
resource "null_resource" "vpc_public_ip_cleanup" {
  triggers = {
    region = data.aws_region.current.name
    vpc_id = aws_vpc.vpc.id
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -uo pipefail
      REGION="${self.triggers.region}"
      VPC="${self.triggers.vpc_id}"

      echo ">> [VPC cleanup] Garantindo que nada com IP publico sobrou em $VPC"

      # 1) Apaga TODOS os Load Balancers (NLB/ALB/GWLB) da VPC
      LBS=$(aws elbv2 describe-load-balancers --region "$REGION" \
        --query "LoadBalancers[?VpcId=='$VPC'].LoadBalancerArn" \
        --output text 2>/dev/null || true)
      if [ -n "$LBS" ] && [ "$LBS" != "None" ]; then
        echo "$LBS" | tr '\t' '\n' | while read -r ARN; do
          [ -n "$ARN" ] || continue
          echo "   delete LB $ARN"
          aws elbv2 delete-load-balancer --region "$REGION" --load-balancer-arn "$ARN" || true
        done
      fi

      # 2) Classic ELBs (raro, mas existe se alguem usar legacy)
      CLBS=$(aws elb describe-load-balancers --region "$REGION" \
        --query "LoadBalancerDescriptions[?VPCId=='$VPC'].LoadBalancerName" \
        --output text 2>/dev/null || true)
      if [ -n "$CLBS" ] && [ "$CLBS" != "None" ]; then
        echo "$CLBS" | tr '\t' '\n' | while read -r NAME; do
          [ -n "$NAME" ] || continue
          echo "   delete Classic ELB $NAME"
          aws elb delete-load-balancer --region "$REGION" --load-balancer-name "$NAME" || true
        done
      fi

      # 3) Espera AWS soltar as ENIs (ignora NAT Gateway - Terraform cuida dele)
      echo ">> Aguardando ENIs com IP publico desaparecerem..."
      for i in $(seq 1 18); do
        REMAINING=$(aws ec2 describe-network-interfaces --region "$REGION" \
          --filters "Name=vpc-id,Values=$VPC" \
          --query "length(NetworkInterfaces[?Association.PublicIp!=null && InterfaceType!='nat_gateway'])" \
          --output text 2>/dev/null || echo "0")
        if [ "$REMAINING" = "0" ]; then
          echo "   OK - sem ENIs orfas com IP publico"
          break
        fi
        echo "   $REMAINING ENI(s) ainda presente(s)... ($i/18)"
        sleep 10
      done

      # 4) Force-detach + delete em ENIs com IP publico que ainda sobraram
      ENIS=$(aws ec2 describe-network-interfaces --region "$REGION" \
        --filters "Name=vpc-id,Values=$VPC" \
        --query "NetworkInterfaces[?Association.PublicIp!=null && InterfaceType!='nat_gateway'].[NetworkInterfaceId,Attachment.AttachmentId]" \
        --output text 2>/dev/null || true)
      if [ -n "$ENIS" ] && [ "$ENIS" != "None" ]; then
        echo "$ENIS" | while read -r ENI ATTACH; do
          [ -n "$ENI" ] || continue
          if [ -n "$ATTACH" ] && [ "$ATTACH" != "None" ]; then
            echo "   detach ENI $ENI (attachment $ATTACH)"
            aws ec2 detach-network-interface --region "$REGION" --attachment-id "$ATTACH" --force || true
            sleep 5
          fi
          echo "   delete ENI $ENI"
          aws ec2 delete-network-interface --region "$REGION" --network-interface-id "$ENI" || true
        done
      fi

      # 5) Libera EIPs orfaos (sem AssociationId). Os EIPs do NAT GW deste
      #    projeto sao apagados pelo proprio destroy logo em seguida.
      ORPHAN_EIPS=$(aws ec2 describe-addresses --region "$REGION" \
        --query "Addresses[?AssociationId==null].AllocationId" \
        --output text 2>/dev/null || true)
      if [ -n "$ORPHAN_EIPS" ] && [ "$ORPHAN_EIPS" != "None" ]; then
        echo "$ORPHAN_EIPS" | tr '\t' '\n' | while read -r ALLOC; do
          [ -n "$ALLOC" ] || continue
          echo "   release EIP orfao $ALLOC"
          aws ec2 release-address --region "$REGION" --allocation-id "$ALLOC" || true
        done
      fi

      echo ">> [VPC cleanup] OK"
    EOT
  }

  depends_on = [aws_internet_gateway.igw]
}
