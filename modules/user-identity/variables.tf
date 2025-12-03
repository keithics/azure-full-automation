variable "identity_names" {
  description = "List of User-Assigned Managed Identity names"
  type        = list(string)
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