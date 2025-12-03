resource "azurerm_key_vault" "keyvaults" {
  for_each = { for kv in var.key_vaults : kv.name => kv }

  name                       = each.value.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tags                       = var.tags
  sku_name                   = each.value.sku
  tenant_id                  = each.value.tenant_id
  enable_rbac_authorization  = each.value.enable_rbac
  purge_protection_enabled   = each.value.purge_protection_enabled
  soft_delete_retention_days = each.value.soft_delete_retention_days
}

#### Roles and Permissions

## UAMI
resource "azurerm_role_assignment" "kv_uami" {
  for_each = {
    for kv in var.key_vaults :
    kv.name => {
      vault_id = azurerm_key_vault.keyvaults[kv.name].id
    }
  }

  scope                = each.value.vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.uami_principal_id
}



## read only
data "azuread_service_principal" "readonly" {
  // toset for dupe readonly_app names
  for_each = toset([
    for kv in var.key_vaults : kv.readonly_app
  ])

  display_name = each.key
}

resource "azurerm_role_assignment" "kv_readonly" {
  for_each = {
    for kv in var.key_vaults :
    kv.name => {
      vault_id     = azurerm_key_vault.keyvaults[kv.name].id
      readonly_app = kv.readonly_app
    }
  }

  scope                = each.value.vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_service_principal.readonly[each.value.readonly_app].object_id
}


## Key Vault Secrets Officer
data "azuread_service_principal" "officer" {
  // toset for dupe officer names
  for_each = toset([
    for kv in var.key_vaults : kv.officer_app
  ])

  display_name = each.key
}

resource "azurerm_role_assignment" "officer" {
  for_each = {
    for kv in var.key_vaults :
    kv.name => {
      vault_id    = azurerm_key_vault.keyvaults[kv.name].id
      officer_app = kv.officer_app
    }
  }

  scope                = each.value.vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_service_principal.officer[each.value.officer_app].object_id
}


## Owners are not automatically owners with RBAC enabled

locals {
  kv_user_pairs = flatten([
    for kv in azurerm_key_vault.keyvaults : [
      for user_id in var.default_owners : {
        key_vault_name = kv.name
        key_vault_id   = kv.id
        assignee_id    = user_id
      }
    ]
  ])

  // we will add SP as UAMI to each of these KV
  kv_user_pairs_sp = flatten([
    for kv in azurerm_key_vault.keyvaults : [
      for user_id in var.default_owners_sp : {
        key_vault_name = kv.name
        key_vault_id   = kv.id
        assignee_id    = user_id
      }
    ]
  ])

}

// Users
resource "azurerm_role_assignment" "kv_admin" {
  for_each = {
    for pair in local.kv_user_pairs :
    "${pair.key_vault_name}-${pair.assignee_id}" => pair
  }

  scope                = each.value.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value.assignee_id
}

// Managed ID ServicePrincipal, usually from main pulse
resource "azurerm_role_assignment" "kv_admin_sp" {
  for_each = {
    for pair in local.kv_user_pairs_sp :
    "${pair.key_vault_name}-${pair.assignee_id}" => pair
  }

  scope                = each.value.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value.assignee_id
  principal_type       = "ServicePrincipal"
}
