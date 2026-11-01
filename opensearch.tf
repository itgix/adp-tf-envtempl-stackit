resource "stackit_opensearch_instance" "this" {
  count = var.create_opensearch ? 1 : 0

  depends_on = [stackit_secretsmanager_instance.this]

  project_id = local.project_id
  name       = local.opensearch_name
  version    = var.opensearch_version
  plan_name  = var.opensearch_plan_name

  parameters = {
    sgw_acl = local.opensearch_acl_cidrs
  }
}

resource "stackit_opensearch_credential" "this" {
  count = var.create_opensearch ? 1 : 0

  project_id  = local.project_id
  instance_id = stackit_opensearch_instance.this[0].instance_id
}

resource "vault_kv_secret_v2" "opensearch_credentials" {
  count = var.create_opensearch && var.create_secrets_manager ? 1 : 0

  mount               = stackit_secretsmanager_instance.this[0].instance_id
  name                = "${var.prefix}-opensearch-credentials"
  delete_all_versions = true
  data_json = jsonencode({
    host     = stackit_opensearch_credential.this[0].host
    port     = stackit_opensearch_credential.this[0].port
    username = stackit_opensearch_credential.this[0].username
    password = stackit_opensearch_credential.this[0].password
  })

  depends_on = [stackit_secretsmanager_instance.this, stackit_secretsmanager_user.writer, stackit_opensearch_credential.this]
}
