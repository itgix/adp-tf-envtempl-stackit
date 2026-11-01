resource "stackit_valkey_instance" "this" {
  count = var.create_redis ? 1 : 0

  depends_on = [stackit_secretsmanager_instance.this]

  project_id = local.project_id
  name       = local.redis_name
  version    = var.redis_version
  plan_name  = var.redis_plan_name

  parameters = {
    sgw_acl = local.redis_acl_cidrs
  }
}

resource "stackit_valkey_credential" "this" {
  count = var.create_redis ? 1 : 0

  project_id  = local.project_id
  instance_id = stackit_valkey_instance.this[0].instance_id
}

resource "vault_kv_secret_v2" "redis_credentials" {
  count = var.create_redis && var.create_secrets_manager ? 1 : 0

  mount               = stackit_secretsmanager_instance.this[0].instance_id
  name                = "${var.prefix}-redis-credentials"
  delete_all_versions = true
  data_json = jsonencode({
    host     = stackit_valkey_credential.this[0].host
    port     = stackit_valkey_credential.this[0].port
    username = stackit_valkey_credential.this[0].username
    password = stackit_valkey_credential.this[0].password
  })

  depends_on = [stackit_secretsmanager_user.writer, stackit_valkey_credential.this]
}
