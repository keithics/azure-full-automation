resource "azuread_application" "this" {
  for_each     = { for app in var.entra_apps : app.display_name => app }
  display_name = each.value.display_name
  description  = try(each.value.description, null)
  owners       = try(each.value.owners, [])
  tags         = [for k, v in try(each.value.tags, {}) : "${k}:${v}"]

  # lifecycle {
  #   prevent_destroy = each.key == "adapp-pulse-user-appflow-dev-ctower" // example only, customize logic as needed
  # }


  dynamic "single_page_application" {
    for_each = try([each.value.single_page_application], [])
    content {
      redirect_uris = single_page_application.value.redirect_uris
    }
  }


  dynamic "web" {
    for_each = try([each.value.web], []) # list with one item or empty list
    content {
      homepage_url  = web.value.homepage_url
      logout_url    = web.value.logout_url
      redirect_uris = web.value.redirect_uris

      implicit_grant {
        access_token_issuance_enabled = try(web.value.implicit_grant.access_token_issuance_enabled, false)
        id_token_issuance_enabled     = try(web.value.implicit_grant.id_token_issuance_enabled, false)
      }
    }
  }
}

resource "azuread_service_principal" "this" {
  for_each                     = { for app in var.entra_apps : app.display_name => app }
  client_id                    = azuread_application.this[each.key].client_id
  app_role_assignment_required = try(each.value.app_role_assignment_required, false)
  owners                       = try(each.value.owners, [])
}

