# Define a local variable `bucket_arn` that defaults to `var.bucket_arn`.
# If `var.bucket_arn` is not provided, it uses the `arn` of an S3 bucket created later in the configuration.
locals {
  bucket_arn = var.bucket_arn != "" ? var.bucket_arn : aws_s3_bucket.bucket.arn
}

# Create an AWS S3 bucket resource named `aws_s3_bucket.bucket` if `var.bucket_arn` is not provided.
resource "aws_s3_bucket" "bucket" {
  count  = var.bucket_arn != "" ? 0 : 1 # Conditionally create the resource based on the presence of `var.bucket_arn`.
  bucket = "${var.codebuild_name}-codebuild-bucket" # Set the bucket name based on the input variable `codebuild_name`.
}

# Create an AWS CodeBuild project resource named `aws_codebuild_project.this`.
resource "aws_codebuild_project" "this" {
  name          = "${var.codebuild_name}-project" # Set the project name based on the input variable `codebuild_name`.
  # Set the project description based on the input variable `codebuild_name`.
  description   = "${var.codebuild_name}_codebuild_project"
  build_timeout = var.build_timeout # Set the build timeout based on the input variable `build_timeout`.
  service_role  = var.service_role_arn # Set the service role based on the input variable `service_role_arn`.

  # Set the project artifacts configuration based on the input variables `artifact_type`.
  artifacts {
    type = var.artifact_type
  }

  # Set the project environment configuration based on the input variables `compute_type`, `codebuild_image`, `codebuild_type`, and `image_pull_credentials_type`.
  environment {
    compute_type                = var.compute_type
    image                       = var.codebuild_image
    type                        = var.codebuild_type
    image_pull_credentials_type = var.image_pull_credentials_type
  }

  # Set the project source configuration based on the input variables `source_type` and `buildspec_filename`.
  source {
    type      = var.source_type
    buildspec = var.buildspec_filename
  }
}

# Create an AWS IAM role resource named `aws_iam_role.codebuild_role`.
resource "aws_iam_role" "codebuild_role" {
  # Set the role name based on the input variable `codebuild_name`.
  name               = "${var.codebuild_name}-codebuild-role"
  # Set the assume role policy based on the policy document `data.aws_iam_policy_document.assume_role_policy`.
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
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
    actions = "sts:AssumeRole"
  }
}

data "aws_iam_policy_document" "codebuild_policy_document" {
  # The first statement grants permission to access the specified S3 bucket and perform specified actions
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

  # The second statement grants permission to perform specified actions on the CodeBuild project itself
  statement {
    effect  = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
  }

  # The list of resources that this policy applies to, in this case the CodeBuild project
  resources = [aws_codebuild_project.this.arn]
}

# Create an AWS IAM policy with the specified name, and associate it with an IAM role and the policy document defined above
resource "aws_iam_policy" "codebuild_policy" {
  name   = "${var.codebuild_name}-codebuild-policy"
  role   = aws_iam_role.codebuild_role
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}