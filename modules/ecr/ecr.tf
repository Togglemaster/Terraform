module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.1.0"

  for_each = toset(var.repository_name)

  repository_name = each.value

  repository_force_delete         = true
  repository_image_tag_mutability = "MUTABLE"
  repository_read_write_access_arns = [aws_iam_role.ecr_role.arn]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = var.tags
}