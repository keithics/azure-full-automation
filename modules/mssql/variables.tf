variable "mssql" {
  type = object({
    name                             = string
    version                          = string
    minimum_tls_version              = string
    key_vault_administrator_login    = string
    key_vault_administrator_password = string
    firewall_rules = map(object({
      start_ip = string
      end_ip   = string
    }))
    databases = list(object({
      name        = string
      sku_name    = string
      collation   = string
      max_size_gb = number
    }))
  })
}

variable "key_vault_id" {
  description = "Key Vault Id"
}


variable "ad_admin_username" {
  description = "Azure AD administrator username for the MSSQL Server."
  type        = string
}

variable "ad_admin_object_id" {
  description = "Azure AD administrator object ID."
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID of the Azure Active Directory."
  type        = string
}

variable "azuread_authentication_only" {
  description = "If true, only Azure AD authentication is allowed."
  type        = bool
  default     = false
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the identities will be created"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the identities"
  type        = map(string)
  default     = {}
}

