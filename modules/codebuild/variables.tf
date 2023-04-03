variable "codebuild_name" {
  type = string
}

variable "bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket used for the CodeBuild project artifacts. If empty, a new S3 bucket will be created."
  default     = ""
  validation {
    condition     = var.bucket_arn == "" || can(regex("^arn:aws:s3:::[a-z0-9.-]{3,63}$", var.bucket_arn))
    error_message = "Bucket ARN must be a valid S3 bucket ARN if provided."
  }
}

variable "build_timeout" {
  type        = number
  description = "The number of minutes after which AWS CodeBuild stops the build if it has not already completed"
  default     = 5
  validation {
    condition     = var.build_timeout > 0 && var.build_timeout <= 480
    error_message = "Build timeout must be a positive integer between 1 and 480"
  }
}

variable "compute_type" {
  type        = string
  description = "The compute type for AWS CodeBuild project"
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition     = can(regex("BUILD_GENERAL\\d+_\\w+", var.compute_type))
    error_message = "Compute type must match the pattern 'BUILD_GENERAL<Number>_<Size>'"
  }

  validation {
    condition     = var.compute_type != "BUILD_GENERAL1_SMALL" || var.compute_type != "BUILD_GENERAL1_MEDIUM" || var.compute_type != "BUILD_GENERAL1_LARGE"
    error_message = "Compute type must be one of 'BUILD_GENERAL1_SMALL', 'BUILD_GENERAL1_MEDIUM', or 'BUILD_GENERAL1_LARGE'"
  }
}

variable "codebuild_image" {
  type        = string
  description = "The CodeBuild image for the project"
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"

  validation {
    condition     = can(regex("[a-z]+/[a-z]+:[0-9].[0-9]", var.codebuild_image))
    error_message = "CodeBuild image must match the pattern <registry>/<image_name>:<version>"
  }
}

variable "codebuild_type" {
  type        = string
  description = "The CodeBuild compute type for the project"
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition     = can(regex("BUILD_GENERAL\\d+_\\w+", var.codebuild_type))
    error_message = "CodeBuild compute type must match the pattern 'BUILD_GENERAL<Number>_<Size>'"
  }

  validation {
    condition     = var.codebuild_type != "BUILD_GENERAL1_SMALL" || var.codebuild_type != "BUILD_GENERAL1_MEDIUM" || var.codebuild_type != "BUILD_GENERAL1_LARGE"
    error_message = "CodeBuild compute type must be one of 'BUILD_GENERAL1_SMALL', 'BUILD_GENERAL1_MEDIUM', or 'BUILD_GENERAL1_LARGE'"
  }
}

variable "artifact_type" {
  type        = string
  description = "The type of artifact to generate from the CodeBuild project"
  default     = "NO_ARTIFACTS"

  validation {
    condition     = var.artifact_type == "NO_ARTIFACTS" || var.artifact_type == "S3" || var.artifact_type == "CODEPIPELINE"
    error_message = "Artifact type must be one of 'NO_ARTIFACTS', 'S3', or 'CODEPIPELINE'"
  }
}

variable "service_role_arn" {
  type        = string
  description = "The ARN of the IAM role used by the CodeBuild project"
  default     = ""

  validation {
    condition     = can(regex("arn:aws:iam::\\d{12}:role/\\S+", var.service_role_arn))
    error_message = "Role ARN must be in the format 'arn:aws:iam::<account_id>:role/<role_name>'"
  }
}

variable "image_pull_credentials_type" {
  type        = string
  description = "The type of credentials to use for pulling the Docker image used in the CodeBuild project"
  default     = "CODEBUILD"

  validation {
    condition     = var.image_pull_credentials_type == "CODEBUILD" || var.image_pull_credentials_type == "SERVICE_ROLE"
    error_message = "Image pull credentials type must be one of 'CODEBUILD' or 'SERVICE_ROLE'"
  }
}

variable "buildspec_filename" {
  type        = string
  description = "The name of the buildspec file to use for the CodeBuild project"
  default     = "buildspec.yml"

  validation {
    condition     = can(regex("\\w+\\.yml$", var.buildspec_filename))
    error_message = "Buildspec filename must end with .yml"
  }
}

variable "source_type" {
  type        = string
  description = "The type of source for the CodeBuild project"
  default     = "NO_SOURCE"

  validation {
    condition     = var.source_type == "NO_SOURCE" || var.source_type == "CODECOMMIT" || var.source_type == "CODEPIPELINE" || var.source_type == "GITHUB" || var.source_type == "GITHUB_ENTERPRISE" || var.source_type == "BITBUCKET" || var.source_type == "S3" || var.source_type == "CODESTAR_SOURCE_CONNECTION"
    error_message = "Source type must be one of 'NO_SOURCE', 'CODECOMMIT', 'CODEPIPELINE', 'GITHUB', 'GITHUB_ENTERPRISE', 'BITBUCKET', 'S3', or 'CODESTAR_SOURCE_CONNECTION'"
  }
}