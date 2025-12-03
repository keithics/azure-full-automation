resource "random_password" "generated" {
  for_each = {
    for s in var.secrets : s.name => s
  }

  length           = 32
  special          = true
  override_special = "!@#$%&*()-_=+"
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = {
    for s in var.secrets : s.name => s
  }

  name         = each.value.name
  key_vault_id = var.kv_id

  value = coalesce(
    try(each.value.value, null),
    try(random_password.generated[each.key].result, null),
    ""
  )

  lifecycle {
    ignore_changes = [
      value,
      tags
    ]
  }
}
