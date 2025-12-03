variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "storage" {
  type = list(object({
    name                       = string
    account_tier               = string
    account_replication_type   = string
    account_kind               = string
    access_tier                = string
    https_traffic_only_enabled = bool
    index_doc                  = optional(string)
    error_doc                  = optional(string)
  }))
}
