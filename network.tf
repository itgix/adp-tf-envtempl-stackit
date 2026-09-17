resource "stackit_network" "this" {
  project_id       = local.project_id
  name             = local.network_name
  ipv4_prefix      = var.network_ipv4_prefix
  routed           = true
  ipv4_nameservers = ["8.8.8.8", "8.8.4.4"]
}
