resource "stackit_secretsmanager_instance" "this" {
  count = var.create_secrets_manager ? 1 : 0

  project_id = stackit_resourcemanager_project.this.project_id
  name       = local.secrets_manager_name
  acls       = [var.network_ipv4_prefix]
}

# Write-enabled user — used by Terraform (local-exec) to store secrets
resource "stackit_secretsmanager_user" "writer" {
  count = var.create_secrets_manager ? 1 : 0

  project_id    = stackit_resourcemanager_project.this.project_id
  instance_id   = stackit_secretsmanager_instance.this[0].instance_id
  description   = "terraform-writer"
  write_enabled = true
}

# Read-only user — used by workloads inside the cluster (ESO or app pods)
resource "stackit_secretsmanager_user" "reader" {
  count = var.create_secrets_manager ? 1 : 0

  project_id    = stackit_resourcemanager_project.this.project_id
  instance_id   = stackit_secretsmanager_instance.this[0].instance_id
  description   = "cluster-reader"
  write_enabled = false
}

