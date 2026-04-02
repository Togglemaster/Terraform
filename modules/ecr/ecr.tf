#============================================
# ECR module
#============================================
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.1.0"

  for_each = toset(var.repository_name)

  repository_name = each.value

  repository_force_delete           = true
  repository_image_tag_mutability   = "MUTABLE"
  repository_read_write_access_arns = [aws_iam_role.ecr_role.arn]

  # Lifecycle policy
  repository_lifecycle_policy = jsonencode({
    # keep only the last 10 images
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      },
      # Remove untagged images after 7 days
      {
        rulePriority = 2,
        description  = "Remove untagged images after 7 days",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 7
        },
        action = { type = "expire" }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}_${var.environment}_sqs"
    }
  )
}