resource "stackit_mongodbflex_instance" "this" {
  count = var.create_mongodb ? 1 : 0

  depends_on = [stackit_secretsmanager_instance.this]

  project_id      = stackit_resourcemanager_project.this.project_id
  name            = local.mongodb_name
  version         = var.mongodb_version
  replicas        = var.mongodb_replicas
  acl             = local.mongodb_acl_list
  backup_schedule = var.mongodb_backup_schedule

  flavor = {
    cpu = var.mongodb_cpu
    ram = var.mongodb_ram
  }

  storage = {
    class = var.mongodb_storage_class
    size  = var.mongodb_storage_size
  }

  options = {
    type = var.mongodb_type
  }
}

resource "stackit_mongodbflex_user" "this" {
  count = var.create_mongodb ? 1 : 0

  project_id  = stackit_resourcemanager_project.this.project_id
  instance_id = stackit_mongodbflex_instance.this[0].instance_id
  username    = "appuser"
  database    = "admin"
  roles       = ["readWriteAnyDatabase"]
}
