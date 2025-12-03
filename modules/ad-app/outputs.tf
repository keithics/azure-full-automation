output "application_ids" {
  value = {
    for k, app in azuread_application.this :
    k => {
      object_id = app.object_id
      id        = app.id
      client_id = app.client_id
    }
  }
}

output "service_principal_ids" {
  value = {
    for k, sp in azuread_service_principal.this :
    k => {
      id        = sp.id
      object_id = sp.object_id
      client_id = sp.client_id
    }
  }
}
