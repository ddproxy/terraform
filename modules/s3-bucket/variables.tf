variable "name" {
  type        = string
  description = "A descriptive name for this S3 bucket"

  validation {
    condition     = length(var.name) > 0
    error_message = "The name cannot be empty"
  }
}