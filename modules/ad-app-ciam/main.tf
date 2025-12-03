resource "azuread_application" "ciam_spa" {

  display_name     = var.app_name
  sign_in_audience = "AzureADMyOrg"
  identifier_uris  = ["api://${var.hostname}"]
  # logo_image       = filebase64("/path/to/logo.png")
  // owners = var.default_owners

  web {
    redirect_uris = []
  }

  single_page_application {
    redirect_uris = var.redirect_uris
  }

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    # known_client_applications = [
    #   azuread_application.known1.client_id,
    #   azuread_application.known2.client_id,
    # ]

    oauth2_permission_scope {
      admin_consent_description  = "Admins and Users"
      admin_consent_display_name = "Admins and Users"
      enabled                    = true
      id                         = "b5473aba-1eb2-41cc-a956-892c942c03bc"
      type                       = "User"
      user_consent_description   = null
      user_consent_display_name  = null
      value                      = "users"
    }

    # oauth2_permission_scope {
    #   admin_consent_description  = "Administer the example application"
    #   admin_consent_display_name = "Administer"
    #   enabled                    = true
    #   id                         = "be98fa3e-ab5b-4b11-83d9-04ba2b7946bc"
    #   type                       = "Admin"
    #   value                      = "administer"
    # }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    # resource_access {
    #   id   = "a154be20-db9c-4678-8ab7-66f6cc099a59" # openid
    #   type = "Scope"
    # }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # profile
      type = "Scope"
    }
    # resource_access {
    #   id   = "14dad69e-099b-42c9-810b-d002981feec1" # email
    #   type = "Scope"
    # }

    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" # offline access
      type = "Scope"
    }
  }


}
#
# resource "azuread_application_password" "ciam_spa_secret" {
#   application_object_id = azuread_application.ciam_spa.id
#   display_name          = "${var.app_name} Default secret"
# }
