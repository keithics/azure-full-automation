output "key_vault_names" {
  description = "The names of the created Key Vaults"
  value = {
    for kv_name, kv in azurerm_key_vault.keyvaults :
    kv_name => kv.name
  }
}

output "key_vault_ids" {
  description = "The IDs of the created Key Vaults"
  value = {
    for kv_name, kv in azurerm_key_vault.keyvaults :
    kv_name => kv.id
  }
}

output "key_vault_uris" {
  description = "The Vault URIs of the created Key Vaults"
  value = {
    for kv_name, kv in azurerm_key_vault.keyvaults :
    kv_name => kv.vault_uri
  }
}
