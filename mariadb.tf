resource "stackit_mariadb_instance" "this" {
  count = var.create_mariadb ? 1 : 0

  depends_on = [stackit_secretsmanager_instance.this]

  project_id = local.project_id
  name       = local.mariadb_name
  version    = var.mariadb_version
  plan_name  = var.mariadb_plan_name

  parameters = {
    sgw_acl = local.mariadb_acl_cidrs
  }
}

resource "stackit_mariadb_credential" "this" {
  count = var.create_mariadb ? 1 : 0

  project_id  = local.project_id
  instance_id = stackit_mariadb_instance.this[0].instance_id
}

resource "vault_kv_secret_v2" "mariadb_credentials" {
  count = var.create_mariadb && var.create_secrets_manager ? 1 : 0

  mount               = stackit_secretsmanager_instance.this[0].instance_id
  name                = "${var.prefix}-mariadb-credentials"
  delete_all_versions = true
  data_json = jsonencode({
    host     = stackit_mariadb_credential.this[0].host
    port     = stackit_mariadb_credential.this[0].port
    username = stackit_mariadb_credential.this[0].username
    password = stackit_mariadb_credential.this[0].password
    uri      = stackit_mariadb_credential.this[0].uri
  })

  depends_on = [stackit_secretsmanager_instance.this, stackit_secretsmanager_user.writer, stackit_mariadb_credential.this]
}
