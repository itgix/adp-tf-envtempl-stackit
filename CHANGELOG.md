# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v1.0.0] - 2026-09-17

### Initial Release

First stable release of the STACKIT environment template — a Terraform module for
provisioning a full STACKIT cloud environment including networking, Kubernetes, managed
databases, and secrets management.

### Added

**Core Infrastructure**
- STACKIT project provisioning with optional reuse of an existing project (`create_project`, `existing_project_id`)
- Network Area provisioning at organization level with optional reuse (`create_network_area`, `existing_network_area_id`)
- Private routed network (VPC equivalent) with configurable CIDR and DNS nameservers
- All resource names derived from a single `prefix` variable for easy multi-tenant reuse

**Kubernetes (SKE)**
- STACKIT Kubernetes Engine (SKE) cluster with configurable Kubernetes version (`kubernetes_version`)
- Single node pool with configurable machine type, min/max node count, and availability zones
- Configurable maintenance window for K8s and OS image updates
- Application Load Balancer (ALB) extension support (`enable_alb_extension`)
- Cluster creation is optional (`create_cluster`)

**Managed Databases** — all optional via toggle variables, all ACL-restricted to the private network CIDR by default
- MariaDB (`create_mariadb`) — configurable version and plan
- PostgresFlex (`create_postgres`) — configurable version, CPU, RAM, storage class/size, backup schedule, retention, replicas
- Redis/Valkey (`create_redis`) — configurable version and plan
- MongoDBFlex (`create_mongodb`) — configurable version, CPU, RAM, storage, backup schedule, point-in-time recovery, instance type (Single/Replica/Sharded)
- OpenSearch (`create_opensearch`) — configurable version and plan
- Per-database additional ACL CIDRs (`*_additional_acl_cidrs`) to extend access beyond the private network

**Secrets Management**
- STACKIT Secrets Manager instance (`create_secrets_manager`) ACL-restricted to the private network
- Writer user (Terraform local-exec) and reader user (cluster workloads / ESO) provisioned automatically
- Database credentials pushed to Secrets Manager via HTTP API using `null_resource` local-exec provisioners
- Secrets stored as JSON objects per database (`mariadb`, `postgres`, `redis`, `mongodb`)

**State Backend**
- Remote state via S3-compatible STACKIT Object Storage backend (`backends/backend.tfvars`)

**Provider**
- STACKIT Terraform provider `stackitcloud/stackit` pinned to `~> 0.115.0`

### Notes
- Cluster name is capped at 11 characters by STACKIT SKE — the `prefix` variable controls this
- PostgresFlex private network placement (`access_scope = "SNA"`) is in private preview; public access with ACL is the default
- STACKIT does not support pod-level IAM (no IRSA equivalent) — workload identity federation via OIDC is documented in the README
- The STACKIT provider does not support writing individual secret values; secrets are pushed via the Secrets Manager HTTP API

[v1.0.0]: https://github.com/your-org/adp-tf-envtempl-stackit/releases/tag/v1.0.0
