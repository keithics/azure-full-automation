output "primary_web_host" {
  description = "Primary web host of the static site"
  value = {
    for name, sa in azurerm_storage_account.static_sites :
    name => sa.primary_web_host
  }
}

output "primary_web_endpoint" {
  description = "Primary web endpoint of the static site"
  value = {
    for name, sa in azurerm_storage_account.static_sites :
    name => sa.primary_web_endpoint
  }
}


output "storage_name" {
  value = {
    for name, sa in azurerm_storage_account.static_sites :
    name => sa.name
  }
}