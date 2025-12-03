output "mssql_server_id" {
  description = "ID of the MSSQL server"
  value       = azurerm_mssql_server.this.id
}

output "mssql_server_name" {
  description = "ID of the MSSQL server"
  value       = azurerm_mssql_server.this.name
}

output "mssql_database_ids" {
  description = "Map of MSSQL database keys to their resource IDs"
  value = {
    for key, db in azurerm_mssql_database.this :
    key => db.id
  }
}

output "mssql_database_names" {
  description = "Map of MSSQL database keys to their names"
  value = {
    for key, db in azurerm_mssql_database.this :
    key => db.name
  }
}

output "mssql_database_list" {
  description = "List of all MSSQL database names"
  value       = [for db in azurerm_mssql_database.this : db.name]
}
