variable "region" {
  description = "AWS region for the state bucket."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the CI role, as <owner>/<repo>."
  type        = string
}

variable "github_environments" {
  description = "GitHub environments allowed to assume the CI role."
  type        = list(string)
  default     = ["dev", "dev-plan"]
}

variable "attach_admin_policy" {
  description = "Attach AdministratorAccess to the CI role. Sandbox only."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
    purpose    = "terraform-state"
  }
}
