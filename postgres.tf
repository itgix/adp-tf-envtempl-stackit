resource "stackit_postgresflex_instance" "this" {
  count = var.create_postgres ? 1 : 0

  depends_on = [stackit_secretsmanager_instance.this]

  project_id      = stackit_resourcemanager_project.this.project_id
  name            = local.postgres_name
  version         = var.postgres_version
  replicas        = var.postgres_replicas
  acl             = local.postgres_acl_list
  backup_schedule = var.postgres_backup_schedule

  flavor = {
    cpu = var.postgres_cpu
    ram = var.postgres_ram
  }

  storage = {
    class = var.postgres_storage_class
    size  = var.postgres_storage_size
  }
}

resource "stackit_postgresflex_user" "this" {
  count = var.create_postgres ? 1 : 0

  project_id  = stackit_resourcemanager_project.this.project_id
  instance_id = stackit_postgresflex_instance.this[0].instance_id
  username    = "appuser"
  roles       = ["login"]
}
