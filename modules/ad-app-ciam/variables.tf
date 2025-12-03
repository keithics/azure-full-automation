variable "tenant_id" {
  description = "CIAM tenant ID"
  type        = string
}

variable "app_name" {
  description = "Display name for the CIAM app"
  type        = string
  default     = "My CIAM SPA"
}

variable "hostname" {
  description = "App identifier"
}

variable "redirect_uris" {
  description = "List of redirect URIs for SPA"
  type        = list(string)
}

variable "default_owners" {
  type = list(string)
}