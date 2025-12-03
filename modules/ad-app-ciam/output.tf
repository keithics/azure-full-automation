output "spa_app_name" {
  value = azuread_application.ciam_spa.display_name
}

output "spa_client_id" {
  value = azuread_application.ciam_spa.client_id
}

output "spa_redirect_uris" {
  value = azuread_application.ciam_spa.single_page_application[0].redirect_uris
}

# output "spa_client_secret" {
#   value     = azuread_application_password.ciam_spa_secret.value
#   sensitive = true
# }
#
