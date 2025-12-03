variable "name" {
  description = "The name of the certificate"
  type        = string
}

variable "key_vault_name" {
  description = "The Name of the Azure Key Vault where the certificate will be stored"
  type        = string
}

variable "hostname" {
  description = "Primary hostname to be used in the certificate subject and SANs"
  type        = string
}

variable "developer_hostname" {
  description = "Developer environment hostname to be added as SAN"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for all key vaults"
}