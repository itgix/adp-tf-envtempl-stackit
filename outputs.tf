# General
output "organization_id" {
  value = var.organization_id
}

output "region" {
  value = var.region
}

# Network Area
output "create_network_area" {
  value = var.create_network_area
}

output "existing_network_area_id" {
  value = var.existing_network_area_id
}

output "network_area_name" {
  value = local.network_area_name
}

output "network_range_prefix" {
  value = var.network_range_prefix
}

output "transfer_network" {
  value = var.transfer_network
}

output "network_area_id" {
  value = local.network_area_id
}

# Project
output "stackit_project_name" {
  value = local.project_name
}

output "owner_email" {
  value = var.owner_email
}

output "create_project" {
  value = var.create_project
}

output "existing_project_id" {
  value = var.existing_project_id
}

output "project_id" {
  value = local.project_id
}

# Network
output "network_name" {
  value = local.network_name
}

output "network_ipv4_prefix" {
  value = var.network_ipv4_prefix
}

output "network_id" {
  value = stackit_network.this.network_id
}

# Cluster
output "create_cluster" {
  value = var.create_cluster
}

output "cluster_name" {
  value = local.cluster_name
}

output "kubernetes_cluster_name" {
  value = local.cluster_name
}

output "kubernetes_version" {
  value = var.kubernetes_version
}

output "node_pool_machine_type" {
  value = var.node_pool_machine_type
}

output "node_pool_min" {
  value = var.node_pool_min
}

output "node_pool_max" {
  value = var.node_pool_max
}

output "node_pool_availability_zones" {
  value = var.node_pool_availability_zones
}

output "cluster_id" {
  value = var.create_cluster ? stackit_ske_cluster.this[0].id : null
}

# Maintenance
output "maintenance_enable_k8s_updates" {
  value = var.maintenance_enable_k8s_updates
}

output "maintenance_enable_os_updates" {
  value = var.maintenance_enable_os_updates
}

output "maintenance_start" {
  value = var.maintenance_start
}

output "maintenance_end" {
  value = var.maintenance_end
}

# MariaDB
output "create_mariadb" {
  value = var.create_mariadb
}

output "mariadb_name" {
  value = var.create_mariadb ? local.mariadb_name : null
}

output "mariadb_version" {
  value = var.create_mariadb ? var.mariadb_version : null
}

output "mariadb_plan_name" {
  value = var.create_mariadb ? var.mariadb_plan_name : null
}

output "mariadb_instance_id" {
  value = var.create_mariadb ? stackit_mariadb_instance.this[0].instance_id : null
}

output "mariadb_host" {
  value = var.create_mariadb ? stackit_mariadb_credential.this[0].host : null
}

output "mariadb_port" {
  value = var.create_mariadb ? stackit_mariadb_credential.this[0].port : null
}

output "mariadb_username" {
  value = var.create_mariadb ? stackit_mariadb_credential.this[0].username : null
}

output "mariadb_password" {
  value     = var.create_mariadb ? stackit_mariadb_credential.this[0].password : null
  sensitive = true
}

output "mariadb_secret_name" {
  value = var.create_mariadb && var.create_secrets_manager ? "${var.prefix}-mariadb-credentials" : null
}

# PostgreSQL
output "postgres_instances" {
  description = "Map of PostgreSQL instance details keyed by instance name."
  value = { for k, v in stackit_postgresflex_instance.this : k => {
    instance_id = v.instance_id
    host        = v.connection_info.write.host
    port        = v.connection_info.write.port
    username    = stackit_postgresflex_user.this[k].username
    secret_name = var.create_secrets_manager ? "${var.prefix}-postgres-${k}-credentials" : null
  }}
}

output "postgres_passwords" {
  description = "Map of PostgreSQL passwords keyed by instance name."
  sensitive   = true
  value       = { for k, v in stackit_postgresflex_user.this : k => v.password }
}

# Redis
output "create_redis" {
  value = var.create_redis
}

output "redis_name" {
  value = var.create_redis ? local.redis_name : null
}

output "redis_version" {
  value = var.create_redis ? var.redis_version : null
}

output "redis_plan_name" {
  value = var.create_redis ? var.redis_plan_name : null
}

output "redis_instance_id" {
  value = var.create_redis ? stackit_valkey_instance.this[0].instance_id : null
}

output "redis_host" {
  value = var.create_redis ? stackit_valkey_credential.this[0].host : null
}

output "redis_port" {
  value = var.create_redis ? stackit_valkey_credential.this[0].port : null
}

output "redis_username" {
  value = var.create_redis ? stackit_valkey_credential.this[0].username : null
}

output "redis_password" {
  value     = var.create_redis ? stackit_valkey_credential.this[0].password : null
  sensitive = true
}

output "redis_secret_name" {
  value = var.create_redis && var.create_secrets_manager ? "${var.prefix}-redis-credentials" : null
}

# MongoDB
output "create_mongodb" {
  value = var.create_mongodb
}

output "mongodb_name" {
  value = var.create_mongodb ? local.mongodb_name : null
}

output "mongodb_version" {
  value = var.create_mongodb ? var.mongodb_version : null
}

output "mongodb_replicas" {
  value = var.create_mongodb ? var.mongodb_replicas : null
}

output "mongodb_type" {
  value = var.create_mongodb ? var.mongodb_type : null
}

output "mongodb_backup_schedule" {
  value = var.create_mongodb ? var.mongodb_backup_schedule : null
}

output "mongodb_cpu" {
  value = var.create_mongodb ? var.mongodb_cpu : null
}

output "mongodb_ram" {
  value = var.create_mongodb ? var.mongodb_ram : null
}

output "mongodb_storage_class" {
  value = var.create_mongodb ? var.mongodb_storage_class : null
}

output "mongodb_storage_size" {
  value = var.create_mongodb ? var.mongodb_storage_size : null
}

output "mongodb_instance_id" {
  value = var.create_mongodb ? stackit_mongodbflex_instance.this[0].instance_id : null
}

output "mongodb_host" {
  value = var.create_mongodb ? stackit_mongodbflex_user.this[0].host : null
}

output "mongodb_port" {
  value = var.create_mongodb ? stackit_mongodbflex_user.this[0].port : null
}

output "mongodb_username" {
  value = var.create_mongodb ? stackit_mongodbflex_user.this[0].username : null
}

output "mongodb_password" {
  value     = var.create_mongodb ? stackit_mongodbflex_user.this[0].password : null
  sensitive = true
}

output "mongodb_secret_name" {
  value = var.create_mongodb && var.create_secrets_manager ? "${var.prefix}-mongodb-credentials" : null
}

# OpenSearch
output "create_opensearch" {
  value = var.create_opensearch
}

output "opensearch_name" {
  value = var.create_opensearch ? local.opensearch_name : null
}

output "opensearch_version" {
  value = var.create_opensearch ? var.opensearch_version : null
}

output "opensearch_plan_name" {
  value = var.create_opensearch ? var.opensearch_plan_name : null
}

output "opensearch_instance_id" {
  value = var.create_opensearch ? stackit_opensearch_instance.this[0].instance_id : null
}

output "opensearch_host" {
  value = var.create_opensearch ? stackit_opensearch_credential.this[0].host : null
}

output "opensearch_port" {
  value = var.create_opensearch ? stackit_opensearch_credential.this[0].port : null
}

output "opensearch_username" {
  value = var.create_opensearch ? stackit_opensearch_credential.this[0].username : null
}

output "opensearch_password" {
  value     = var.create_opensearch ? stackit_opensearch_credential.this[0].password : null
  sensitive = true
}

output "opensearch_secret_name" {
  value = var.create_opensearch && var.create_secrets_manager ? "${var.prefix}-opensearch-credentials" : null
}

# Secrets Manager
output "secrets_manager_instance_id" {
  value = var.create_secrets_manager ? stackit_secretsmanager_instance.this[0].instance_id : null
}

output "secrets_manager_writer_username" {
  value     = var.create_secrets_manager ? stackit_secretsmanager_user.writer[0].username : null
  sensitive = true
}

output "secrets_manager_writer_password" {
  value     = var.create_secrets_manager ? stackit_secretsmanager_user.writer[0].password : null
  sensitive = true
}

output "secrets_manager_reader_username" {
  value     = var.create_secrets_manager ? stackit_secretsmanager_user.reader[0].username : null
  sensitive = true
}

output "secrets_manager_reader_password" {
  value     = var.create_secrets_manager ? stackit_secretsmanager_user.reader[0].password : null
  sensitive = true
}

output "create_dns_service_account" {
  value = var.create_dns_service_account
}

output "external_dns_sa_key_secret_name" {
  value = var.create_service_accounts && var.create_dns_service_account ? "${var.prefix}-ext-dns-key" : null
}

output "create_alb_service_account" {
  value = var.create_alb_service_account
}

output "alb_controller_sa_key_secret_name" {
  value = var.create_service_accounts && var.create_alb_service_account ? "${var.prefix}-alb-ctrl-key" : null
}

# Object Storage
output "object_storage_buckets" {
  value = { for k, v in stackit_objectstorage_bucket.this : k => {
    url                   = v.url_path_style
    credentials_group_urn = stackit_objectstorage_credentials_group.this[k].urn
    secret_name           = var.create_secrets_manager ? "${var.prefix}-${k}-credentials" : null
  }}
}
