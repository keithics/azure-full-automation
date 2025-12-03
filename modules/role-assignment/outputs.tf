output "role_assignments" {
  description = "List of role assignments created"
  value = [
    for v in azurerm_role_assignment.this :
    {
      id                   = v.id
      principal_id         = v.principal_id
      role_definition_id   = v.role_definition_id
      role_definition_name = v.role_definition_name
      scope                = v.scope
    }
  ]
}