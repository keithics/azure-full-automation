output "certificate_id" {
  description = "The ID of the Key Vault certificate"
  value       = azurerm_key_vault_certificate.this.id
}

output "certificate_name" {
  description = "The name of the certificate"
  value       = azurerm_key_vault_certificate.this.name
}

output "certificate_version" {
  description = "The version of the certificate"
  value       = azurerm_key_vault_certificate.this.version
}

output "versionless_secret_id" {
  description = "The secret version id of the certificate"
  value       = azurerm_key_vault_certificate.this.versionless_secret_id
}
