resource "azurerm_storage_account" "static_sites" {
  for_each = { for site in var.storage : site.name => site }

  name                       = each.value.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  account_tier               = each.value.account_tier
  account_replication_type   = each.value.account_replication_type
  account_kind               = each.value.account_kind
  access_tier                = each.value.access_tier
  https_traffic_only_enabled = each.value.https_traffic_only_enabled


  tags = var.tags

}

resource "azurerm_storage_account_static_website" "this" {
  for_each = { for site in var.storage : site.name => site }

  storage_account_id = azurerm_storage_account.static_sites[each.key].id
  index_document     = lookup(each.value, "index_doc", "index.html")
  error_404_document = lookup(each.value, "error_doc", "index.html")
}
