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
