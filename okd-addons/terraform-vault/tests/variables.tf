variable "vault_k8s_auth_token_reviewer_jwt" {
  type        = string
  description = "jwt token of the service account used for authentication with vault"
}

variable "vault_data" {
  type        = string
  description = "yaml containing vault configuration"
}
