## Must be hard coded, as this will be used as a config per project
## Project name will be use as a prefix in ALL environment
locals {
  project_name = "pulse"
  organization = "Squarcle-Consulting-Ltd"
  location     = "ukwest"
}

inputs = merge(
  {
    project_name = local.project_name
    organization = local.organization
    location     = local.location
  }
)