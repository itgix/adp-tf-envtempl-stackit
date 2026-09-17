locals {
  network_area_id = var.create_network_area ? stackit_network_area.this[0].network_area_id : var.existing_network_area_id
  project_id      = var.create_project ? stackit_resourcemanager_project.this[0].project_id : var.existing_project_id
}

resource "stackit_network_area" "this" {
  count = var.create_network_area ? 1 : 0

  organization_id = var.organization_id
  name            = local.network_area_name
}

resource "stackit_network_area_region" "this" {
  count = var.create_network_area ? 1 : 0

  organization_id = var.organization_id
  network_area_id = stackit_network_area.this[0].network_area_id

  ipv4 = {
    transfer_network = var.transfer_network
    network_ranges = [
      { prefix = var.network_range_prefix }
    ]
  }
}
