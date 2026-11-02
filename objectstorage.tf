resource "stackit_objectstorage_bucket" "this" {
  for_each = var.object_storage_buckets

  project_id = local.project_id
  name       = each.key
}

resource "stackit_objectstorage_credentials_group" "this" {
  for_each = var.object_storage_buckets

  project_id = local.project_id
  name       = "${var.prefix}-${each.key}"
}

resource "stackit_objectstorage_credential" "this" {
  for_each = var.object_storage_buckets

  project_id           = local.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.this[each.key].credentials_group_id
}

resource "aws_s3_bucket_policy" "this" {
  for_each = { for k, v in var.object_storage_buckets : k => v if v.policy != null }

  provider = aws.stackit_s3
  bucket   = each.key
  policy   = each.value.policy

  depends_on = [stackit_objectstorage_bucket.this]
}

resource "vault_kv_secret_v2" "object_storage_credentials" {
  for_each = var.create_secrets_manager ? var.object_storage_buckets : {}

  mount               = stackit_secretsmanager_instance.this[0].instance_id
  name                = "${var.prefix}-${each.key}-credentials"
  delete_all_versions = true
  data_json = jsonencode({
    bucket            = each.key
    access_key        = stackit_objectstorage_credential.this[each.key].access_key
    secret_access_key = stackit_objectstorage_credential.this[each.key].secret_access_key
    endpoint          = "https://object.storage.${var.region}.onstackit.cloud"
    credentials_group_urn = stackit_objectstorage_credentials_group.this[each.key].urn
  })

  depends_on = [stackit_secretsmanager_user.writer, stackit_objectstorage_credential.this]
}
