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
output "project_name" {
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
  value = local.mariadb_name
}

output "mariadb_version" {
  value = var.mariadb_version
}

output "mariadb_plan_name" {
  value = var.mariadb_plan_name
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

# PostgreSQL
output "create_postgres" {
  value = var.create_postgres
}

output "postgres_name" {
  value = local.postgres_name
}

output "postgres_version" {
  value = var.postgres_version
}

output "postgres_replicas" {
  value = var.postgres_replicas
}

output "postgres_backup_schedule" {
  value = var.postgres_backup_schedule
}

output "postgres_cpu" {
  value = var.postgres_cpu
}

output "postgres_ram" {
  value = var.postgres_ram
}

output "postgres_storage_class" {
  value = var.postgres_storage_class
}

output "postgres_storage_size" {
  value = var.postgres_storage_size
}

output "postgres_instance_id" {
  value = var.create_postgres ? stackit_postgresflex_instance.this[0].instance_id : null
}

output "postgres_host" {
  value = var.create_postgres ? stackit_postgresflex_user.this[0].host : null
}

output "postgres_port" {
  value = var.create_postgres ? stackit_postgresflex_user.this[0].port : null
}

output "postgres_username" {
  value = var.create_postgres ? stackit_postgresflex_user.this[0].username : null
}

# Redis
output "create_redis" {
  value = var.create_redis
}

output "redis_name" {
  value = local.redis_name
}

output "redis_version" {
  value = var.redis_version
}

output "redis_plan_name" {
  value = var.redis_plan_name
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

# MongoDB
output "create_mongodb" {
  value = var.create_mongodb
}

output "mongodb_name" {
  value = local.mongodb_name
}

output "mongodb_version" {
  value = var.mongodb_version
}

output "mongodb_replicas" {
  value = var.mongodb_replicas
}

output "mongodb_type" {
  value = var.mongodb_type
}

output "mongodb_backup_schedule" {
  value = var.mongodb_backup_schedule
}

output "mongodb_cpu" {
  value = var.mongodb_cpu
}

output "mongodb_ram" {
  value = var.mongodb_ram
}

output "mongodb_storage_class" {
  value = var.mongodb_storage_class
}

output "mongodb_storage_size" {
  value = var.mongodb_storage_size
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

# OpenSearch
output "create_opensearch" {
  value = var.create_opensearch
}

output "opensearch_name" {
  value = local.opensearch_name
}

output "opensearch_version" {
  value = var.opensearch_version
}

output "opensearch_plan_name" {
  value = var.opensearch_plan_name
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

# Secrets Manager
output "secrets_manager_instance_id" {
  value = var.create_secrets_manager ? stackit_secretsmanager_instance.this[0].instance_id : null
}

output "secrets_manager_reader_username" {
  value     = var.create_secrets_manager ? stackit_secretsmanager_user.reader[0].username : null
  sensitive = true
}