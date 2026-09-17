resource "stackit_resourcemanager_project" "this" {
  count = var.create_project ? 1 : 0

  parent_container_id = var.organization_id
  name                = local.project_name
  owner_email         = var.owner_email

  labels = {
    networkArea = local.network_area_id
  }
}
