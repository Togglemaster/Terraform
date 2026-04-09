terraform {
  backend "s3" {
    bucket = "terraform-state-3-apostolos"
    key    = "Togglemaster/Production/terraform.tfstate"
    region = "us-east-1"
  }
}
