locals {
  // Define a local variable `name` with a value of "tf-${var.name}" if `var.name` is not empty,
  // or "tf" if `var.name` is empty.
  name = var.name != "" ? "tf-${var.name}" : "tf"
}


// Create an ECR repository resource with the name "${local.name}-ecr" and image tag mutability set to `var.mutability`.
// Also enable image scanning when images are pushed to the repository.
resource "aws_ecr_repository" "this" {
  name                 = "${local.name}-ecr"
  image_tag_mutability = var.mutability

  image_scanning_configuration {
    scan_on_push = true
  }
}

// Define a data block to create an IAM policy document to allow read access to the ECR repository for the
// `var.allowed_read_principals` AWS principals.
data "aws_iam_policy_document" "this" {
  count = length(var.allowed_read_principals) > 0 ? 1 : 0

  statement {
    sid     = "ECRRead"
    effect  = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]

    // Allow access to the ECR repository for the `var.allowed_read_principals` AWS principals.
    principals {
      identifiers = var.allowed_read_principals
      type        = "AWS"
    }
  }
}

// Create an ECR repository policy resource to allow read access to the repository for the
// `var.allowed_read_principals` AWS principals.
resource "aws_ecr_repository_policy" "this" {
  count      = length(var.allowed_read_principals) > 0 ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.this[0].json
}

// Define two outputs to return the ECR repository and its name.
output "repository" {
  description = "The ECR repository"
  value       = aws_ecr_repository.this
}

output "repository_name" {
  description = "The ECR repository name"
  value       = aws_ecr_repository.this.name
}