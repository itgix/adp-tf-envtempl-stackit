resource "stackit_secretsmanager_instance" "this" {
  count = var.create_secrets_manager ? 1 : 0

  project_id = local.project_id
  name       = local.secrets_manager_name
  acls       = [var.network_ipv4_prefix]
}

# Write-enabled user — used by Terraform (local-exec) to store secrets
resource "stackit_secretsmanager_user" "writer" {
  count = var.create_secrets_manager ? 1 : 0

  project_id    = local.project_id
  instance_id   = stackit_secretsmanager_instance.this[0].instance_id
  description   = "terraform-writer"
  write_enabled = true
}

# Read-only user — used by workloads inside the cluster (ESO or app pods)
resource "stackit_secretsmanager_user" "reader" {
  count = var.create_secrets_manager ? 1 : 0

  project_id    = local.project_id
  instance_id   = stackit_secretsmanager_instance.this[0].instance_id
  description   = "cluster-reader"
  write_enabled = false
}

# Service account for the ALB controller with alb.admin role
resource "stackit_service_account" "alb_controller" {
  count = var.create_alb_service_account ? 1 : 0

  project_id = local.project_id
  name       = "${var.prefix}-alb-controller"
}

resource "stackit_service_account_key" "alb_controller" {
  count = var.create_alb_service_account ? 1 : 0

  project_id            = local.project_id
  service_account_email = stackit_service_account.alb_controller[0].email
}

resource "stackit_authorization_project_role_assignment" "alb_controller" {
  count = var.create_alb_service_account ? 1 : 0

  resource_id = local.project_id
  subject     = "serviceaccount:${stackit_service_account.alb_controller[0].email}"
  role        = "alb.admin"
}

# Store the service account key in Secrets Manager via Vault provider
resource "vault_kv_secret_v2" "alb_controller" {
  count = var.create_alb_service_account && var.create_secrets_manager ? 1 : 0

  mount               = stackit_secretsmanager_instance.this[0].instance_id
  name                = "alb-controller-sa-key"
  delete_all_versions = true
  data_json = jsonencode({
    value = stackit_service_account_key.alb_controller[0].json
  })
}

# Store ESO reader credentials in Secrets Manager so ESO can bootstrap itself
resource "vault_kv_secret_v2" "eso_reader_credentials" {
  count = var.create_secrets_manager ? 1 : 0

  mount               = stackit_secretsmanager_instance.this[0].instance_id
  name                = "eso-reader-credentials"
  delete_all_versions = true
  data_json = jsonencode({
    username = stackit_secretsmanager_user.reader[0].username
    password = stackit_secretsmanager_user.reader[0].password
  })
}
