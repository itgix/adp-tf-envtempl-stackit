resource "stackit_ske_cluster" "this" {
  count = var.create_cluster ? 1 : 0

  project_id             = local.project_id
  name                   = local.cluster_name
  kubernetes_version_min = var.kubernetes_version

  node_pools = [
    {
      name               = "pool-1"
      machine_type       = var.node_pool_machine_type
      minimum            = var.node_pool_min
      maximum            = var.node_pool_max
      availability_zones = var.node_pool_availability_zones
    }
  ]

  network = {
    id = stackit_network.this.network_id
  }

  maintenance = {
    enable_kubernetes_version_updates    = var.maintenance_enable_k8s_updates
    enable_machine_image_version_updates = var.maintenance_enable_os_updates
    start                                = var.maintenance_start
    end                                  = var.maintenance_end
  }

  extensions = {
    application_load_balancer = {
      enabled = var.enable_alb_extension
    }
  }
}
