data "azurerm_key_vault_secret" "sql_admin_login" {
  name         = var.mssql.key_vault_administrator_login
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = var.mssql.key_vault_administrator_password
  key_vault_id = var.key_vault_id
}


resource "azurerm_mssql_server" "this" {
  name                          = var.mssql.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.mssql.version
  administrator_login           = data.azurerm_key_vault_secret.sql_admin_login.value
  administrator_login_password  = data.azurerm_key_vault_secret.sql_admin_password.value
  minimum_tls_version           = var.mssql.minimum_tls_version
  public_network_access_enabled = true
  tags                          = var.tags

  azuread_administrator {
    login_username              = var.ad_admin_username
    object_id                   = var.ad_admin_object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = var.azuread_authentication_only
  }
}

resource "azurerm_mssql_firewall_rule" "this" {
  for_each = var.mssql.firewall_rules

  name             = each.key
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

resource "azurerm_mssql_database" "this" {
  for_each = { for db in var.mssql.databases : db.name => db }

  name        = "sqldb-${each.value.name}"
  server_id   = azurerm_mssql_server.this.id
  sku_name    = each.value.sku_name
  collation   = each.value.collation
  max_size_gb = each.value.max_size_gb
  tags        = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
