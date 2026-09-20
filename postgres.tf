resource "stackit_postgresflex_instance" "this" {
  count = var.create_postgres ? 1 : 0

  depends_on = [stackit_secretsmanager_instance.this]

  project_id      = local.project_id
  name            = local.postgres_name
  version         = var.postgres_version
  backup_schedule = var.postgres_backup_schedule
  flavor_id       = var.postgres_flavor_id
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
