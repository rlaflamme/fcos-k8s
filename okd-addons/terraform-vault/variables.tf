variable "kubernetes_host" {
  type        = string
  description = "kubernetes target host for authentication with vault"
}

variable "kubernetes_ca_cert" {
  type        = string
  description = "kubernetes target host ca certificates"
}

variable "vault_k8s_auth_token_reviewer_jwt" {
  type        = string
  description = "jwt token of the service account used for authentication with vault"
}

variable "vault_data" {
  type        = string
  description = "yaml containing vault configuration"
}

