data "stackit_postgresflex_flavors" "this" {
  for_each   = var.postgres_instances
  project_id = local.project_id
}

resource "stackit_postgresflex_instance" "this" {
  for_each = var.postgres_instances

  depends_on = [stackit_secretsmanager_instance.this]

  project_id      = local.project_id
  name            = "${var.prefix}-postgres-${each.key}"
  version         = each.value.version
  backup_schedule = each.value.backup_schedule
  flavor_id = one([
    for f in data.stackit_postgresflex_flavors.this[each.key].flavors :
    f.id if f.cpu == each.value.cpu && f.memory == each.value.ram && lower(f.node_type) == lower(each.value.node_type)
  ])
  retention_days = each.value.retention_days

  network = {
    acl = concat([var.network_ipv4_prefix], each.value.additional_acl_cidrs, var.additional_acl_cidrs, var.postgres_additional_acl_cidrs, var.create_cluster ? stackit_ske_cluster.this[0].egress_address_ranges : [])
  }

  storage = {
    class = each.value.storage_class
    size  = each.value.storage_size
  }
}

resource "stackit_postgresflex_user" "this" {
  for_each = var.postgres_instances

  project_id  = local.project_id
  instance_id = stackit_postgresflex_instance.this[each.key].instance_id
  username    = "appuser"
  roles       = ["login"]
}

resource "vault_kv_secret_v2" "postgres_credentials" {
  for_each = var.create_secrets_manager ? var.postgres_instances : {}

  mount               = stackit_secretsmanager_instance.this[0].instance_id
  name                = "${var.prefix}-postgres-${each.key}-credentials"
  delete_all_versions = true
  data_json = jsonencode({
    host     = stackit_postgresflex_instance.this[each.key].connection_info.write.host
    port     = stackit_postgresflex_instance.this[each.key].connection_info.write.port
    username = stackit_postgresflex_user.this[each.key].username
    password = stackit_postgresflex_user.this[each.key].password
    database = "postgres"
  })

  depends_on = [stackit_secretsmanager_instance.this, stackit_secretsmanager_user.writer, stackit_postgresflex_user.this]
}
