terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.115.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
  experiments    = ["iam"]
}

provider "aws" {
  alias      = "stackit_s3"
  region     = var.region
  access_key = length(var.object_storage_buckets) > 0 ? one(values(stackit_objectstorage_credential.this)).access_key : "placeholder"
  secret_key = length(var.object_storage_buckets) > 0 ? one(values(stackit_objectstorage_credential.this)).secret_access_key : "placeholder"

  endpoints {
    s3 = "https://object.storage.${var.region}.onstackit.cloud"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  s3_use_path_style           = true
}

provider "vault" {
  address          = "https://prod.sm.eu01.stackit.cloud"
  skip_child_token = true

  auth_login_userpass {
    username = stackit_secretsmanager_user.writer[0].username
    password = stackit_secretsmanager_user.writer[0].password
  }
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
  opensearch_name      = "${var.prefix}-opensearch"
  secrets_manager_name = "${var.prefix}-secrets"

  mariadb_acl_cidrs    = join(",", concat([var.network_ipv4_prefix], var.mariadb_additional_acl_cidrs, var.create_cluster ? stackit_ske_cluster.this[0].egress_address_ranges : []))
  postgres_acl_list    = concat([var.network_ipv4_prefix], var.postgres_additional_acl_cidrs, var.create_cluster ? stackit_ske_cluster.this[0].egress_address_ranges : [])
  redis_acl_cidrs      = join(",", concat([var.network_ipv4_prefix], var.redis_additional_acl_cidrs, var.create_cluster ? stackit_ske_cluster.this[0].egress_address_ranges : []))
  mongodb_acl_list     = concat([var.network_ipv4_prefix], var.mongodb_additional_acl_cidrs, var.create_cluster ? stackit_ske_cluster.this[0].egress_address_ranges : [])
  opensearch_acl_cidrs = join(",", concat([var.network_ipv4_prefix], var.opensearch_additional_acl_cidrs, var.create_cluster ? stackit_ske_cluster.this[0].egress_address_ranges : []))
}
