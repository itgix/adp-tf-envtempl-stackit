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
