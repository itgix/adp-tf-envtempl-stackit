resource "stackit_mongodbflex_instance" "this" {
  count = var.create_mongodb ? 1 : 0

  depends_on = [stackit_secretsmanager_instance.this]

  project_id      = local.project_id
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
    type                       = var.mongodb_type
    point_in_time_window_hours = var.mongodb_point_in_time_window_hours
  }
}

resource "stackit_mongodbflex_user" "this" {
  count = var.create_mongodb ? 1 : 0

  project_id  = local.project_id
  instance_id = stackit_mongodbflex_instance.this[0].instance_id
  username    = "appuser"
  database    = "admin"
  roles       = ["readWriteAnyDatabase"]
}

resource "vault_kv_secret_v2" "mongodb_credentials" {
  count = var.create_mongodb && var.create_secrets_manager ? 1 : 0

  mount               = stackit_secretsmanager_instance.this[0].instance_id
  name                = "${var.prefix}-mongodb-credentials"
  delete_all_versions = true
  data_json = jsonencode({
    host     = stackit_mongodbflex_user.this[0].host
    port     = stackit_mongodbflex_user.this[0].port
    username = stackit_mongodbflex_user.this[0].username
    password = stackit_mongodbflex_user.this[0].password
    database = stackit_mongodbflex_user.this[0].database
  })

  depends_on = [stackit_secretsmanager_instance.this, stackit_secretsmanager_user.writer, stackit_mongodbflex_user.this]
}
