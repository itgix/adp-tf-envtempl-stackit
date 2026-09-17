variable "create_project" {
  description = "Whether to create a new STACKIT project. If false, existing_project_id must be set."
  type        = bool
  default     = true
}

variable "existing_project_id" {
  description = "ID of an existing STACKIT project to use when create_project is false."
  type        = string
  default     = null

  validation {
    condition     = var.existing_project_id != null || var.create_project == true
    error_message = "existing_project_id must be set when create_project is false."
  }
}

variable "create_network_area" {
  description = "Whether to create a new Network Area. If false, existing_network_area_id must be set."
  type        = bool
  default     = true
}

variable "existing_network_area_id" {
  description = "ID of an existing Network Area to use when create_network_area is false."
  type        = string
  default     = null

  validation {
    condition     = var.existing_network_area_id != null || var.create_network_area == true
    error_message = "existing_network_area_id must be set when create_network_area is false."
  }
}

variable "organization_id" {
  description = "STACKIT Organization ID"
  type        = string
}

variable "region" {
  description = "STACKIT default region (e.g. eu01)"
  type        = string
  default     = "eu01"
}

variable "prefix" {
  description = "Prefix used for all resource names (e.g. itgix -> itgix-k8s, itgix-postgres, etc.)"
  type        = string
  default     = "itgix"
}


variable "network_range_prefix" {
  description = "CIDR prefix for the network range"
  type        = string
  default     = "10.0.0.0/8"
}

variable "transfer_network" {
  description = "CIDR for internal routing between network area and projects"
  type        = string
  default     = "192.168.0.0/24"
}

variable "owner_email" {
  description = "Email of the project owner"
  type        = string
}

variable "network_ipv4_prefix" {
  description = "IPv4 CIDR for the project network (must be between /24 and /29)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "create_cluster" {
  description = "Whether to create the SKE Kubernetes cluster"
  type        = bool
  default     = true
}

variable "enable_alb_extension" {
  description = "Whether to enable the STACKIT Application Load Balancer extension on the SKE cluster"
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = "Minimum Kubernetes version for the SKE cluster"
  type        = string
  default     = "1.35"
}

variable "node_pool_machine_type" {
  description = "Machine type for the node pool (e.g. g2i.2 = 2CPU/8GB)"
  type        = string
  default     = "g2i.2"
}

variable "node_pool_min" {
  description = "Minimum number of nodes in the pool"
  type        = number
  default     = 3
}

variable "node_pool_max" {
  description = "Maximum number of nodes in the pool (set equal to min to disable autoscaling)"
  type        = number
  default     = 4
}

variable "node_pool_availability_zones" {
  description = "Availability zones for the node pool (e.g. [\"eu01-1\", \"eu01-2\", \"eu01-3\"])"
  type        = list(string)
  default     = ["eu01-1", "eu01-2", "eu01-3"]
}

variable "maintenance_enable_k8s_updates" {
  description = "Whether to enable automatic Kubernetes version updates"
  type        = bool
  default     = false
}

variable "maintenance_enable_os_updates" {
  description = "Whether to enable automatic OS image version updates"
  type        = bool
  default     = false
}

variable "maintenance_start" {
  description = "Start time of the maintenance window (e.g. 01:00:00Z)"
  type        = string
  default     = "01:00:00Z"
}

variable "maintenance_end" {
  description = "End time of the maintenance window (e.g. 02:00:00Z)"
  type        = string
  default     = "02:00:00Z"
}

# MariaDB
variable "create_mariadb" {
  description = "Whether to create a MariaDB instance"
  type        = bool
  default     = false
}

variable "mariadb_version" {
  description = "MariaDB version"
  type        = string
  default     = "10.6"
}

variable "mariadb_plan_name" {
  description = "MariaDB plan name (e.g. stackit-mariadb-1-1-10)"
  type        = string
  default     = "stackit-mariadb-1-1-10"
}

variable "postgres_flavor_id" {
  description = "Flavor ID for the PostgreSQL instance (e.g. '2.4-single'). Use stackit_postgresflex_flavors datasource to list available flavors."
  type        = string
  default     = "2.4-single"
}

# PostgreSQL
variable "create_postgres" {
  description = "Whether to create a PostgresFlex instance"
  type        = bool
  default     = false
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "postgres_replicas" {
  description = "Number of PostgreSQL replicas (1 = single, 3 = HA)"
  type        = number
  default     = 1
}

variable "additional_acl_cidrs" {
  description = "Additional CIDRs to add to the ACL of all databases, on top of network_ipv4_prefix"
  type        = list(string)
  default     = []
}

variable "mariadb_additional_acl_cidrs" {
  description = "Additional CIDRs to allow access to MariaDB, on top of network_ipv4_prefix"
  type        = list(string)
  default     = []
}

variable "postgres_additional_acl_cidrs" {
  description = "Additional CIDRs to allow access to PostgresFlex, on top of network_ipv4_prefix"
  type        = list(string)
  default     = []
}

variable "redis_additional_acl_cidrs" {
  description = "Additional CIDRs to allow access to Redis, on top of network_ipv4_prefix"
  type        = list(string)
  default     = []
}

variable "postgres_backup_schedule" {
  description = "Backup schedule in cron format"
  type        = string
  default     = "0 2 * * *"
}

variable "postgres_cpu" {
  description = "Number of CPUs for the PostgreSQL instance"
  type        = number
  default     = 2
}

variable "postgres_ram" {
  description = "Amount of RAM in GB for the PostgreSQL instance"
  type        = number
  default     = 4
}

variable "postgres_storage_class" {
  description = "Storage class for the PostgreSQL instance (e.g. premium-perf2-stackit)"
  type        = string
  default     = "premium-perf2-stackit"
}

variable "postgres_storage_size" {
  description = "Storage size in GB for the PostgreSQL instance"
  type        = number
  default     = 20
}

# Redis
variable "create_redis" {
  description = "Whether to create a Redis instance"
  type        = bool
  default     = false
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "7.2"
}

variable "redis_plan_name" {
  description = "Redis plan name (e.g. stackit-redis-1-1-10)"
  type        = string
  default     = "stackit-redis-1-1-10"
}

# MongoDB
variable "create_mongodb" {
  description = "Whether to create a MongoDBFlex instance"
  type        = bool
  default     = false
}

variable "mongodb_version" {
  description = "MongoDB version"
  type        = string
  default     = "7.0"
}

variable "mongodb_replicas" {
  description = "Number of MongoDB replicas (1 = Single, 3 = Replica)"
  type        = number
  default     = 1
}

variable "mongodb_type" {
  description = "MongoDB instance type: Single, Replica, or Sharded"
  type        = string
  default     = "Single"
}

variable "mongodb_point_in_time_window_hours" {
  description = "Point-in-time recovery window in hours for MongoDB"
  type        = number
  default     = 24
}

variable "mongodb_backup_schedule" {
  description = "Backup schedule in cron format"
  type        = string
  default     = "0 2 * * *"
}

variable "mongodb_cpu" {
  description = "Number of CPUs for the MongoDB instance"
  type        = number
  default     = 2
}

variable "mongodb_ram" {
  description = "Amount of RAM in GB for the MongoDB instance"
  type        = number
  default     = 4
}

variable "mongodb_storage_class" {
  description = "Storage class for the MongoDB instance (e.g. premium-perf2-stackit)"
  type        = string
  default     = "premium-perf2-stackit"
}

variable "mongodb_storage_size" {
  description = "Storage size in GB for the MongoDB instance"
  type        = number
  default     = 20
}

variable "mongodb_additional_acl_cidrs" {
  description = "Additional CIDRs to allow access to MongoDB, on top of network_ipv4_prefix"
  type        = list(string)
  default     = []
}

# Secrets Manager
variable "create_secrets_manager" {
  description = "Whether to create a STACKIT Secrets Manager instance and store database credentials in it"
  type        = bool
  default     = false
}


