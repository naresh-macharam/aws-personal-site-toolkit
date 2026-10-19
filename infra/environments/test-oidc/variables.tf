variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "github_org" {
  description = "Your GitHub username, e.g. \"naresh852\""
  type        = string
}

variable "test_repo" {
  description = "A throwaway repo name to test against, e.g. \"oidc-test\". Create an empty repo with this exact name before applying."
  type        = string
}

variable "import_existing_provider" {
  description = <<-EOT
    Set true if you already have the GitHub OIDC provider from earlier
    manual setup, and want this config to just reference it instead of
    creating a new one. You'll still need to run the terraform import
    command shown in the module's main.tf comments once, manually.
  EOT
  type    = bool
  default = false
}
