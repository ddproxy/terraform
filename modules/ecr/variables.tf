variable "name" {
  type    = string
  default = "tf-ecr"
}

variable "mutability" {
  type    = string
  default = "MUTABLE"
  validation {
    condition = can(regex("^MUTABLE$|^IMMUTABLE$", var.mutability))
    error_message = "The mutability variable must be either 'MUTABLE' or 'IMMUTABLE'"
  }
}

variable "allowed_read_principals" {
  type    = list(string)
  default = []
  validation {
    condition     = length(var.allowed_read_principals) <= 10
    error_message = "The allowed_read_principals list cannot contain more than 10 values"
  }
}