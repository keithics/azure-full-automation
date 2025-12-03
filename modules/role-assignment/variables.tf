variable "assignments" {
  description = "List of role assignment entries with principal_id, role_definition_name, and scope"
  type = list(object({
    principal_id         = string
    role_definition_name = string
    scope                = string
  }))
}
