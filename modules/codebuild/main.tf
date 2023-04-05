# If `var.bucket_arn` is not provided, it uses the `arn` of an S3 bucket created later in the configuration.
locals {
  bucket_arn       = var.bucket_arn != "" ? var.bucket_arn : aws_s3_bucket.bucket[0].arn
  service_role_arn = var.service_role_arn != "" ? var.service_role_arn : aws_iam_role.codebuild_role[0].arn
}

# Create an AWS S3 bucket resource named `aws_s3_bucket.bucket` if `var.bucket_arn` is not provided.
resource "aws_s3_bucket" "bucket" {
  count  = var.bucket_arn != "" ? 0 : 1
  bucket = "${var.codebuild_name}-codebuild-bucket"
}

resource "aws_s3_bucket_acl" "bucket" {
  count  = var.bucket_arn != "" ? 0 : 1
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  count                   = var.bucket_arn != "" ? 0 : 1
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_codebuild_project" "this" {
  name          = "${var.codebuild_name}-project"
  description   = "${var.codebuild_name}_codebuild_project"
  build_timeout = var.build_timeout
  service_role  = local.service_role_arn

  artifacts {
    type = var.artifact_type
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.codebuild_image
    type                        = var.codebuild_type
    image_pull_credentials_type = var.image_pull_credentials_type
  }

  source {
    type      = var.source_type
    buildspec = var.buildspec_filename
  }
}

resource "aws_iam_role" "codebuild_role" {
  count              = var.service_role_arn != "" ? 0 : 1
  name               = "${var.codebuild_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "codebuild_policy" {
  count  = var.service_role_arn != "" ? 0 : 1
  role   = aws_iam_role.codebuild_role[0].name
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}

# Define a policy document in `data.aws_iam_policy_document.assume_role_policy` that specifies the permissions required by CodeBuild to assume the IAM role created earlier.
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "codebuild.amazonaws.com"
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "codebuild_policy_document" {
  # Grants permission to access the specified S3 bucket and perform specified actions
  statement {
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*"
    ]
  }

  # Grants permission to perform specified actions on the CodeBuild project itself
  statement {
    effect  = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [aws_codebuild_project.this.arn]
  }
}