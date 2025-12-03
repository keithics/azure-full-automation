output "key_vault_secret_ids" {
  description = "IDs of the created secrets"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.id }
}
