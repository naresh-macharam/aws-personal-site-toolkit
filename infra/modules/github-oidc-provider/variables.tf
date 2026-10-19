variable "create_provider" {
  description = "true = create a new OIDC provider (fresh AWS account). false = look up an existing one instead (your case, since yours was created manually before this module existed)."
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
