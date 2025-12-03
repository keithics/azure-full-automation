variable "entra_apps" {
  description = "List of Entra applications to create"
  type = list(object({
    display_name                 = string
    description                  = optional(string)
    owners                       = optional(list(string), [])
    tags                         = optional(map(string), {})
    prevent_destroy              = optional(bool, true)
    app_role_assignment_required = optional(bool)
    single_page_application = optional(object({
      redirect_uris = optional(list(string), [])
    }), {})

    web = optional(object({
      homepage_url  = optional(string, null)
      logout_url    = optional(string, null)
      redirect_uris = optional(list(string), [])

      implicit_grant = optional(object({
        access_token_issuance_enabled = optional(bool, false)
        id_token_issuance_enabled     = optional(bool, false)
        }), {
        access_token_issuance_enabled = false
        id_token_issuance_enabled     = false
      })
    }), {})
  }))
}
