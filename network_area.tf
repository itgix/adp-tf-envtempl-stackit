locals {
  network_area_id = var.create_network_area ? stackit_network_area.this[0].network_area_id : var.existing_network_area_id
}

resource "stackit_network_area" "this" {
  count = var.create_network_area ? 1 : 0

  organization_id  = var.organization_id
  name             = local.network_area_name
  transfer_network = var.transfer_network

  network_ranges = [
    { prefix = var.network_range_prefix }
  ]
}
