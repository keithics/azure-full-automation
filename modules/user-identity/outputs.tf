output "identity_ids" {
  description = "Map of identity names to their resource IDs"
  value = {
    for name, id in azurerm_user_assigned_identity.this : name => id.id
  }
}

output "client_ids" {
  description = "Map of identity names to their client IDs"
  value = {
    for name, id in azurerm_user_assigned_identity.this : name => id.client_id
  }
}

output "principal_ids" {
  description = "Map of identity names to their principal IDs"
  value = {
    for name, id in azurerm_user_assigned_identity.this : name => id.principal_id
  }
}
