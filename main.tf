terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.48.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://object.storage.eu01.onstackit.cloud"
    }
    region                      = "eu01"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    skip_requesting_account_id  = true
  }
}

provider "stackit" {
  default_region = var.region
}

locals {
  network_area_name  = "${var.prefix}-network-area"
  project_name       = "${var.prefix}-project"
  network_name       = "${var.prefix}-network"
  cluster_name       = "${var.prefix}-k8s"
  mariadb_name       = "${var.prefix}-mariadb"
  postgres_name      = "${var.prefix}-postgres"
  redis_name         = "${var.prefix}-redis"
  mongodb_name       = "${var.prefix}-mongodb"
  secrets_manager_name = "${var.prefix}-secrets"

  mariadb_acl_cidrs  = join(",", concat([var.network_ipv4_prefix], var.mariadb_additional_acl_cidrs))
  postgres_acl_list  = concat([var.network_ipv4_prefix], var.postgres_additional_acl_cidrs)
  redis_acl_cidrs    = join(",", concat([var.network_ipv4_prefix], var.redis_additional_acl_cidrs))
  mongodb_acl_list   = concat([var.network_ipv4_prefix], var.mongodb_additional_acl_cidrs)
}
