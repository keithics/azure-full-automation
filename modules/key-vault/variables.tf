variable "resource_group_name" {
  type        = string
  description = "Resource group name for all key vaults"
}

variable "location" {
  type        = string
  description = "Azure region for all key vaults"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all key vaults"
}

variable "key_vaults" {
  description = "List of key vaults to create"
  type = list(object({
    name                       = string
    sku                        = string
    tenant_id                  = string
    enable_rbac                = bool
    purge_protection_enabled   = bool
    soft_delete_retention_days = number
    readonly_app               = string
    officer_app                = string
  }))
}

variable "default_owners" {
  type        = list(string)
  description = "List of user object IDs to assign RBAC roles to each Key Vault"
}

variable "default_owners_sp" {
  type        = list(string)
  description = "List of SP object IDs to assign RBAC roles to each Key Vault"
}


variable "uami_principal_id" {
  type        = string
  description = "uami_principal_id"
}