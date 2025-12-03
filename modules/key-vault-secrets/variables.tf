variable "secrets" {
  description = "List of secrets to create. Each secret includes a name and value."
  type = list(object({
    name   = string
    value  = optional(string)
    random = optional(bool)
  }))
}

variable "kv_id" {
  description = "The ID of the Azure Key Vault to store the secrets in."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all secrets."
  type        = map(string)
  default     = {}
}
