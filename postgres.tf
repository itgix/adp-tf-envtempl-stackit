data "stackit_postgresflex_flavors" "this" {
  count      = var.create_postgres ? 1 : 0
  project_id = local.project_id
}

locals {
  postgres_flavor_id = var.create_postgres ? one([
    for f in data.stackit_postgresflex_flavors.this[0].flavors :
    f.id if f.cpu == var.postgres_cpu && f.memory == var.postgres_ram && f.node_type == var.postgres_node_type
  ]) : null
}

resource "stackit_postgresflex_instance" "this" {
  count = var.create_postgres ? 1 : 0

  depends_on = [stackit_secretsmanager_instance.this]

  project_id      = local.project_id
  name            = local.postgres_name
  version         = var.postgres_version
  backup_schedule = var.postgres_backup_schedule
  flavor_id       = local.postgres_flavor_id
  retention_days  = var.postgres_retention_days

  network = {
    acl = local.postgres_acl_list
  }

  storage = {
    class = var.postgres_storage_class
    size  = var.postgres_storage_size
  }
}

resource "stackit_postgresflex_user" "this" {
  count = var.create_postgres ? 1 : 0

  project_id  = local.project_id
  instance_id = stackit_postgresflex_instance.this[0].instance_id
  username    = "appuser"
  roles       = ["login"]
}
