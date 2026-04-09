#-----------------------------
#Criando bucket para backend - Execução local
#-----------------------------
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "terraform-state-3-apostolos"
}

#-----------------------------
#Ativa versionamento do bucket
#-----------------------------
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}

#-----------------------------
#Ativa criptografia do bucket
#-----------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
