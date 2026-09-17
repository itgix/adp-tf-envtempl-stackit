resource "stackit_redis_instance" "this" {
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

resource "stackit_redis_credential" "this" {
  count = var.create_redis ? 1 : 0

  project_id  = local.project_id
  instance_id = stackit_redis_instance.this[0].instance_id
}
