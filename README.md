$ stackit auth login
$ export STACKIT_SERVICE_ACCOUNT_TOKEN="$(stackit auth get-access-token)"
$ export AWS_ACCESS_KEY_ID="bucket-access-key-id"
$ export AWS_SECRET_ACCESS_KEY="bucket-secret-access-key"
$ terraform init -backend-config=config/dev/eu01/backend.tfvars
$ terraform plan --var-file config/dev/eu01/terraform.tfvars
$ terraform apply --var-file config/dev/eu01/terraform.tfvars

STACKIT CLOUD - TERRAFORM GETTING STARTED GUIDE
=================================================

OVERALL RESOURCE HIERARCHY
---------------------------
  Organization
  ├── Network Area          (org level - defines shared IP space across projects)
  │   ├── network_ranges    (the usable CIDR pool, e.g. 10.0.0.0/8)
  │   └── transfer_network  (internal routing CIDR, e.g. 192.168.0.0/24)
  └── Project               (attached to the Network Area via a label)
      ├── Network           (VPC equivalent, CIDR carved from network_ranges)
      └── SKE Cluster       (Kubernetes cluster, deployed into the Network)
          └── Node Pool     (group of worker VMs)


CREATION ORDER (Terraform handles this automatically via references)
--------------------------------------------------------------------
  1. Network Area
  2. Project  (references Network Area ID via label)
  3. Network  (references Project ID, CIDR from Network Area range)
  4. SKE Cluster  (references Project ID + Network ID)


FINDING YOUR ORGANIZATION ID
-----------------------------
Option A - Via CLI:
  stackit organization list

Option B - Via Portal:
  1. Go to portal.stackit.cloud
  2. Click on your Organization name in the top left
  3. Go to Organization Settings or Members
  4. The Organization ID is displayed there


PREREQUISITES
-------------
- Terraform v1.0+
- STACKIT CLI: https://github.com/stackitcloud/stackit-cli


CLI INSTALLATION (Linux amd64)
------------------------------
  # Download and extract
  curl -LO https://github.com/stackitcloud/stackit-cli/releases/download/v0.72.0/stackit-cli_0.72.0_linux_amd64.tar.gz
  tar -xzf stackit-cli_0.72.0_linux_amd64.tar.gz
  sudo mv stackit /usr/local/bin/

  # Or via .deb package
  curl -LO https://github.com/stackitcloud/stackit-cli/releases/download/v0.72.0/stackit_0.72.0_linux_amd64.deb
  sudo dpkg -i stackit_0.72.0_linux_amd64.deb

  # Verify
  stackit --version


AUTHENTICATION
--------------
Option A - Personal account via CLI (easiest for local development):
  NOTE: A project is NOT required for this. You only need your STACKIT portal credentials.

  1. Run: stackit auth login
  2. A browser window will open - log in with your STACKIT portal credentials

Option B - Service Account (recommended for automation):
  NOTE: A project IS required to create a service account.

  1. Go to STACKIT Portal -> your project -> Service Accounts
  2. Create a service account and assign necessary roles
  3. Generate a key (JSON)
  4. export STACKIT_SERVICE_ACCOUNT_KEY_PATH=/path/to/key.json

Option C - Token-based:
  export STACKIT_SERVICE_ACCOUNT_TOKEN=<your_token>


PREFIX VARIABLE
---------------
All resource names are derived from a single `prefix` variable defined in terraform.tfvars.
Changing this one value renames everything — the project, network, cluster, all databases,
and the secrets manager instance.

  prefix = "itgix"  ->  itgix-project, itgix-network, itgix-postgres, itgix-secrets, etc.
  prefix = "acme"   ->  acme-project,  acme-network,  acme-postgres,  acme-secrets,  etc.

The cluster name uses the prefix directly (without a suffix) to stay within the
11-character limit imposed by STACKIT SKE.

To reuse this setup for a different project or client, just change prefix in terraform.tfvars.


RUNNING TERRAFORM
-----------------
Before running any Terraform command, export a short-lived access token using the CLI:

  export STACKIT_SERVICE_ACCOUNT_TOKEN="$(stackit auth get-access-token)"

NOTE: This token is short-lived, so run this command each time you start a new terminal session.

Then:
  terraform init
  terraform plan
  terraform apply


TERRAFORM PROVIDER
------------------
STACKIT has an official Terraform provider: stackitcloud/stackit
Registry: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs
GitHub:   https://github.com/stackitcloud/terraform-provider-stackit

Basic provider configuration (main.tf):
  terraform {
    required_providers {
      stackit = {
        source  = "stackitcloud/stackit"
        version = "~> 0.48.0"
      }
    }
  }

  provider "stackit" {}

Run "terraform init" to download the provider.


STEP 1 - NETWORK AREA
----------------------
Defined at the Organization level. Provides shared IP space across projects.

- network_ranges:    the usable CIDR pool for all projects (e.g. 10.0.0.0/8 = 16M addresses)
- transfer_network:  internal CIDR used by STACKIT for routing between projects and the area
                     (e.g. 192.168.0.0/24 = 256 addresses, not used by workloads)

Controlled via variables:
  create_network_area = true   -> creates a new Network Area
  create_network_area = false  -> uses an existing one, existing_network_area_id must be set

NOTE: If create_network_area = false and existing_network_area_id is not set, Terraform
      will throw a validation error immediately.

  resource "stackit_network_area" "this" {
    organization_id  = var.organization_id
    name             = var.network_area_name
    transfer_network = var.transfer_network
    network_ranges   = [{ prefix = var.network_range_prefix }]
  }


STEP 2 - PROJECT
-----------------
Logical container for resources. Attached to the Network Area via a label.

  resource "stackit_resourcemanager_project" "this" {
    parent_container_id = var.organization_id
    name                = var.project_name
    owner_email         = var.owner_email
    labels = {
      networkArea = stackit_network_area.this.network_area_id
    }
  }


STEP 3 - NETWORK
-----------------
The VPC equivalent inside a project. CIDR must be within the Network Area's network_ranges.
Set routed = true so it can communicate with other networks in the area.

IMPORTANT: ipv4_nameservers is required - without it, nodes cannot join the Kubernetes cluster
because they have no DNS resolution. Use public DNS servers like Google's (8.8.8.8, 8.8.4.4)
or your own internal DNS.

Prefix length must be between /24 and /29.

  resource "stackit_network" "this" {
    project_id       = stackit_resourcemanager_project.this.project_id
    name             = var.network_name
    ipv4_prefix      = var.network_ipv4_prefix   # e.g. 10.1.0.0/25, carved from 10.0.0.0/8
    routed           = true
    ipv4_nameservers = ["8.8.8.8", "8.8.4.4"]
  }


STEP 4 - SKE KUBERNETES CLUSTER
---------------------------------
Managed Kubernetes (built on Gardener). Deployed into the project network.

NOTES:
- Cluster name must be max 11 characters
- Use newer generation machine types (e.g. g2i.2, not g1.2 which is deprecated)
- Creation takes around 16 minutes
- The short-lived token may expire during creation, just re-export and re-run apply:
    export STACKIT_SERVICE_ACCOUNT_TOKEN="$(stackit auth get-access-token)"
    terraform apply

- kubernetes_version_min: minimum K8s version (e.g. "1.35")
- node_pools: list of worker node groups
  - minimum/maximum: node count (set equal to disable autoscaling, or min < max to enable)
  - machine_type: VM size (see machine types below)
  - availability_zones: spread nodes across zones for HA

  resource "stackit_ske_cluster" "this" {
    project_id             = stackit_resourcemanager_project.this.project_id
    name                   = var.cluster_name
    kubernetes_version_min = "1.35"

    node_pools = [
      {
        name               = "pool-1"
        machine_type       = "g1.2"
        minimum            = 3
        maximum            = 4
        availability_zones = ["eu01-1", "eu01-2", "eu01-3"]
      }
    ]

    network = {
      id = stackit_network.this.network_id
    }
  }


MACHINE TYPES (eu01 region)
----------------------------
Family prefixes:
  c = Compute optimized  (low RAM)   e.g. c1.2 = 2CPU/4GB,  c1.3 = 4CPU/8GB
  g = General purpose    (balanced)  e.g. g1.2 = 2CPU/8GB,  g1.3 = 4CPU/16GB
  m = Memory optimized   (high RAM)  e.g. m1.2 = 2CPU/16GB, m1.3 = 4CPU/32GB
  b = Big memory                     e.g. b1.2 = 2CPU/32GB, b1.3 = 4CPU/64GB
  s = Storage optimized              e.g. s1.3 = 4CPU/4GB
  n = GPU nodes                      e.g. n1.14d.g1, n2.14d.g1

List all available types:
  stackit ske options machine-types --region eu01


AVAILABILITY ZONES (eu01 region)
----------------------------------
  eu01-m  (management zone)
  eu01-1
  eu01-2
  eu01-3


KUBERNETES (SKE)
----------------
STACKIT Kubernetes Engine (SKE) is built on top of Gardener (open-source, originally by SAP).
Gardener uses Kubernetes to manage Kubernetes clusters.

Key concepts:
- Shoot clusters  = user-facing workload clusters (what you create)
- Seed clusters   = manage the shoots
- Garden cluster  = control plane of everything


NETWORKING CONCEPTS
--------------------
Network Area vs VPC:
  Network Area  ~ AWS IPAM       (org-level IP planning, not where resources live)
  Network       ~ AWS VPC        (project-level isolated network)
  Subnet        ~ AWS Subnet

Transfer Network:
  Reserved CIDR used internally by STACKIT for routing between the Network Area
  and attached projects. Not used by workloads. A /24 is sufficient.
  Must not overlap with network_ranges or on-premise networks.
  Hard to change once set - plan carefully upfront.


DATABASES (MariaDB, PostgreSQL, Redis, MongoDB)
------------------------------------------------
All databases are controlled via toggle variables in terraform.tfvars:
  create_mariadb  = true/false
  create_postgres = true/false
  create_redis    = true/false
  create_mongodb  = true/false

POSTGRESFLEX vs SQL SERVER FLEX vs MARIADB:
  MariaDB:
  - Fork of MySQL, created by original MySQL developers after Oracle acquired MySQL
  - Open-source, free to use (pay for infrastructure only)
  - Drop-in replacement for MySQL - fully MySQL compatible
  - Best for migrating from MySQL or apps using MySQL drivers/ORMs
  - Used by WordPress, Drupal, Magento and similar frameworks

  PostgresFlex:
  - Open-source, free to use (pay for infrastructure only)
  - SQL standard compliant, runs on Linux
  - Supports JSON, extensions (PostGIS, pgvector, etc.)
  - Best for cloud-native and open-source stacks
  - Better than MariaDB for complex queries and large datasets

  SQL Server Flex:
  - Microsoft proprietary, includes MS license (more expensive)
  - Uses T-SQL dialect, traditionally used in Windows/.NET environments
  - Best for migrating existing on-premise SQL Server workloads to STACKIT

  Summary:
    Feature            MariaDB            PostgresFlex       SQL Server Flex    MongoDBFlex
    -----------        ------------       ------------       ---------------    -----------
    Cost               Lower              Lower              Higher (MS lic.)   Lower
    Type               Relational         Relational         Relational         Document (NoSQL)
    MySQL compatible   Yes (drop-in)      No                 No                 No
    SQL dialect        MySQL-like         PostgreSQL         T-SQL              No SQL (BSON/JSON)
    Stack              Any                Linux/open-source  Windows/.NET       Any
    Migration from     MySQL              Oracle, others     On-premise SQL Srv MongoDB/NoSQL
    Cloud-native       Yes                Yes                Less common        Yes
    Licensing          Open-source        Open-source        MS proprietary     Open-source
    Best for           MySQL migrations   Complex/modern     Windows workloads  JSON/document data

MONGODBFLEX:
  - Open-source NoSQL document database
  - Stores data as JSON-like documents (BSON) instead of rows/tables
  - Best for flexible schemas, hierarchical data, and high write throughput
  - Supports three instance types:
      Single  -> 1 replica, no HA, for dev/test
      Replica -> 3 replicas, HA, for production
      Sharded -> horizontally scaled, for very large datasets
  - ACL restricted to network_ipv4_prefix by default
  - Extend access via: mongodb_additional_acl_cidrs = ["<cidr>"]

PRIVATE NETWORK SUPPORT:

  MariaDB:
  - Runs on STACKIT's shared managed infrastructure
  - Does NOT support placement inside your private network
  - Network access is controlled via sgw_acl (comma-separated CIDRs)
  - To restrict access to your private network only:
      parameters = { sgw_acl = "10.1.0.0/25" }

  Redis:
  - Same as MariaDB - shared managed infrastructure, no private network placement
  - Network access controlled via sgw_acl:
      parameters = { sgw_acl = "10.1.0.0/25" }

  PostgresFlex:
  - Has a network block with access_scope field
  - access_scope = "SNA"    -> STACKIT Network Area (private network) - PRIVATE PREVIEW only
  - access_scope = "PUBLIC" -> public access
  - Private network placement is currently in private preview (not available for all accounts)
  - Without private preview access, restrict via acl:
      acl = ["10.1.0.0/25"]

SUMMARY:
  Database       Private Network    Access Control
  -----------    ---------------    --------------
  MariaDB        No                 sgw_acl (CIDR list)
  Redis          No                 sgw_acl (CIDR list)
  PostgresFlex   Preview only       acl (CIDR list) or network.access_scope = "SNA"

ACL CONFIGURATION:
  By default, all databases are restricted to network_ipv4_prefix (e.g. 10.1.0.0/25).
  This means only resources inside your private network can access the databases.

  Each database has its own variable to add extra CIDRs independently:
    mariadb_additional_acl_cidrs  = ["<cidr1>", "<cidr2>"]
    postgres_additional_acl_cidrs = ["<cidr1>", "<cidr2>"]
    redis_additional_acl_cidrs    = ["<cidr1>", "<cidr2>"]

  network_ipv4_prefix is always included automatically - you only need to add the extra ones.

  Example - allow your office VPN only for PostgreSQL:
    postgres_additional_acl_cidrs = ["203.0.113.0/24"]


GETTING DATABASE CREDENTIALS
-----------------------------
Credentials are created automatically by Terraform when a database is enabled.
They are stored in the Terraform state and exposed as outputs.

Get all non-sensitive outputs (host, port, username for all enabled databases):
  terraform output

Get a specific value:
  terraform output redis_host
  terraform output redis_port
  terraform output redis_username

Get the password (sensitive, not shown by default):
  terraform state show stackit_redis_credential.this[0]

Same pattern applies for all databases:
  terraform state show stackit_mariadb_credential.this[0]
  terraform state show stackit_postgresflex_user.this[0]
  terraform state show stackit_mongodbflex_user.this[0]

All fields available per database:
  MariaDB    -> host, port, username, password, uri
  PostgreSQL -> host (connection_info.write.host), port, username, password
  Redis      -> host, port, username, password, uri, load_balanced_host
  MongoDB    -> host, port, username, password, uri

NOTE: Credentials do not expire. They are static username/password pairs valid
      until explicitly deleted or rotated via rotate_when_changed.


KUBECONFIG
----------
To download the kubeconfig for the SKE cluster via the STACKIT CLI:

  export STACKIT_SERVICE_ACCOUNT_TOKEN="$(stackit auth get-access-token)"

  # Merges into ~/.kube/config by default
  stackit ske kubeconfig create itgix-k8s --project-id <project_id>

  # Or save to a specific file
  stackit ske kubeconfig create itgix-k8s --project-id <project_id> --filepath ./kubeconfig.yaml


LOGGING INTO THE CLUSTER
-------------------------
After downloading the kubeconfig, set the kubectl context to the cluster:

  kubectl config use-context itgix-k8s

Verify the connection:
  kubectl get nodes

NOTE: The kubeconfig token is short-lived. If kubectl opens a browser login prompt
      (redirecting to Open-Xchange/STACKIT identity provider), it means the token
      has expired. To fix it, refresh the token and regenerate the kubeconfig:

  export STACKIT_SERVICE_ACCOUNT_TOKEN="$(stackit auth get-access-token)"
  stackit ske kubeconfig create itgix-k8s --project-id <project_id>
  kubectl config use-context itgix-k8s


STATEFUL APPLICATIONS IN SKE
-----------------------------
For stateful applications in Kubernetes you need Persistent Volumes (PVs).
In STACKIT SKE, this is handled via StorageClasses that provision STACKIT
block storage automatically using the OpenStack Cinder CSI driver.

STACKIT SKE comes with the following StorageClasses pre-installed:
  NAME                             DEFAULT   PROVISIONER
  premium-perf0-stackit                      cinder.csi.openstack.org
  premium-perf1-stackit            YES       cinder.csi.openstack.org
  premium-perf2-stackit                      cinder.csi.openstack.org
  premium-perf4-stackit                      cinder.csi.openstack.org
  premium-perf6-stackit                      cinder.csi.openstack.org
  premium-perf8-stackit                      cinder.csi.openstack.org
  premium-perf10-stackit                     cinder.csi.openstack.org
  premium-perf12-stackit                     cinder.csi.openstack.org
  premium-perf13-stackit                     cinder.csi.openstack.org
  premium-perf14-stackit                     cinder.csi.openstack.org
  premium-perf15-stackit                     cinder.csi.openstack.org
  premium-perf16-stackit                     cinder.csi.openstack.org
  premium-perf17-stackit                     cinder.csi.openstack.org
  premium-perf18-stackit                     cinder.csi.openstack.org
  premium-perf19-stackit                     cinder.csi.openstack.org
  premium-perf20-stackit                     cinder.csi.openstack.org
  premium-perf21-stackit                     cinder.csi.openstack.org
  premium-perf29-stackit                     cinder.csi.openstack.org

The number represents the performance/IOPS tier:
  - Lower number = lower performance, cheaper  (e.g. premium-perf0-stackit)
  - Higher number = higher IOPS, more expensive (e.g. premium-perf10-stackit)
  - Default is premium-perf1-stackit

NOTE: These storage class names are also used in the database Terraform resources
      (postgres_storage_class, mongodb_storage_class) - they must match exactly.

Option A - Let Kubernetes handle it (recommended):
  No Terraform changes needed. Define a PersistentVolumeClaim in your
  Kubernetes manifests and the CSI driver will automatically provision
  the block storage from STACKIT.

  Example PVC manifest:
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: my-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: premium-perf2-stackit
      resources:
        requests:
          storage: 10Gi

Option B - Pre-provision volumes via Terraform:
  STACKIT has block storage resources in the provider (stackit_volume).
  This is useful if you want to manage the lifecycle of volumes via Terraform
  and attach them to your cluster nodes manually.

NOTE: For most stateful workloads (databases, message queues, etc.) Option A
      is the recommended approach as it integrates natively with Kubernetes
      StatefulSets and handles volume lifecycle automatically.


SECRETS MANAGEMENT
------------------
STACKIT has a native Secret Manager service available via Terraform:
  stackit_secretsmanager_instance  -> the secret store instance
  stackit_secretsmanager_user      -> credentials to access the instance

It stores and retrieves static secrets via API. Think of it like AWS Secrets Manager
(not a dynamic secrets engine like HashiCorp Vault).

TERRAFORM SETUP:
  This project creates the following resources when create_secrets_manager = true:

  - stackit_secretsmanager_instance  -> the secrets store, ACL-restricted to network_ipv4_prefix
  - stackit_secretsmanager_user (writer) -> write-enabled, used by Terraform local-exec to push secrets
  - stackit_secretsmanager_user (reader) -> read-only, for workloads inside the cluster
  - null_resource per database -> calls the Secrets Manager API via curl to store credentials

  NOTE: The STACKIT Terraform provider does not have a resource for writing individual secret
  values. Secrets are pushed via the Secrets Manager HTTP API using a local-exec provisioner.
  The null_resource re-runs automatically if credentials change (via triggers).

  Secrets are stored as JSON objects under these keys:
    mariadb   -> { host, port, username, password, uri }
    postgres  -> { host, port, username, password }
    redis     -> { host, port, username, password, uri }
    mongodb   -> { host, port, username, password, uri }

  Toggle:
    create_secrets_manager = true   -> creates the instance and pushes all enabled DB credentials
    create_secrets_manager = false  -> nothing is created (default)

  NOTE: create_secrets_manager = true only makes sense if at least one database is also enabled.
  The secrets for disabled databases are simply skipped.

DATABASE CREDENTIALS:
  Each database has a corresponding credential/user resource created automatically:
    MariaDB    -> stackit_mariadb_credential     (auto-generated username + password)
    PostgreSQL -> stackit_postgresflex_user       (username: appuser, role: login)
    Redis      -> stackit_redis_credential        (auto-generated username + password)
    MongoDB    -> stackit_mongodbflex_user         (username: appuser, database: admin, role: readWriteAnyDatabase)

  These credentials are always created when the database is enabled, regardless of
  create_secrets_manager. If secrets manager is also enabled, they get pushed there automatically.

CONNECTING FROM KUBERNETES PODS:
  Pods inside the cluster connect to databases over the network like any external service.
  The ACL on each database only allows connections from network_ipv4_prefix (10.1.0.0/25).
  Since SKE nodes live in that network, pods pass the ACL check automatically.

  Flow:
    Pod (source IP in 10.1.0.0/25)
      -> TCP connection to DB hostname (e.g. mariadb-xxxxx.stackit.cloud:3306)
      -> ACL check: source IP matches sgw_acl -> allowed
      -> authenticates with username + password
      -> connected

  Pods get the hostname and credentials from a Kubernetes Secret, either:
    - Written directly by Terraform (kubernetes_secret resource)
    - Synced by ESO from STACKIT Secret Manager (recommended)

  Database credentials do NOT expire - they are static username/password pairs.
  Unlike STACKIT API tokens, there is no TTL unless you explicitly rotate them.

INJECTING SECRETS INTO PODS VIA ESO:
  For injecting secrets into Kubernetes, the recommended approach is External Secrets
  Operator (ESO), which pulls secrets from STACKIT Secret Manager and syncs them into
  native Kubernetes Secrets. Pods then consume regular K8s Secrets - no SDK or API calls
  needed from application code.

  Flow:
    STACKIT Secret Manager  ->  ESO (running in SKE)  ->  Kubernetes Secret  ->  Pod

  ESO is installed via Helm and configured with a ClusterSecretStore pointing to
  STACKIT's Secret Manager endpoint, authenticated with the reader user credentials
  output by Terraform (secrets_manager_reader_username / secrets_manager_reader_password).

  Example ClusterSecretStore:
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: stackit-secrets-manager
    spec:
      provider:
        stackit:
          projectID: <project_id>
          instanceID: <secrets_manager_instance_id>
          auth:
            username: <reader_username>
            password: <reader_password>

  Example ExternalSecret:
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: mariadb-credentials
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: stackit-secrets-manager
        kind: ClusterSecretStore
      target:
        name: mariadb-credentials
      data:
        - secretKey: host
          remoteRef:
            key: mariadb
            property: host
        - secretKey: password
          remoteRef:
            key: mariadb
            property: password

Alternative - HashiCorp Vault:
  STACKIT does not offer a managed Vault service. You can self-host Vault inside
  your SKE cluster if you need dynamic secrets, PKI, or secret rotation.
  This is more complex but gives you the full Vault feature set.


IAM - SERVICE ACCOUNTS AND ROLES
---------------------------------
STACKIT does NOT have pod-level IAM roles built into SKE (no equivalent of AWS IRSA
or GCP Workload Identity natively integrated with the scheduler).

Instead, STACKIT provides three building blocks:

  1. Service Accounts (stackit_service_account)
     - Project-level identity, gets an email like: myapp@sa.stackit.cloud
     - Used to authenticate against STACKIT APIs

  2. Role Assignments (stackit_authorization_project_role_assignment)
     - Assigns a role to a service account on a project
     - Available roles: reader, editor, owner (query all roles via CLI - see below)
     - NOTE: This resource is marked experimental in the Terraform provider

  3. Service Account Keys (stackit_service_account_key)
     - Long-lived JSON key generated for a service account
     - Can be stored as a Kubernetes Secret and mounted into pods
     - Supports TTL and rotation via rotate_when_changed

Query available roles for a project:
  stackit curl https://authorization.api.stackit.cloud/v2/project/<project_id>/roles

Terraform example:
  resource "stackit_service_account" "myapp" {
    project_id = var.project_id
    name       = "myapp"
  }

  resource "stackit_authorization_project_role_assignment" "myapp" {
    resource_id = var.project_id
    role        = "editor"
    subject     = stackit_service_account.myapp.email
  }

  resource "stackit_service_account_key" "myapp" {
    project_id            = var.project_id
    service_account_email = stackit_service_account.myapp.email
    ttl_days              = 90
  }

  # Store the key as a Kubernetes Secret (after cluster is created)
  resource "kubernetes_secret" "myapp_sa_key" {
    metadata { name = "stackit-sa-key" }
    data = {
      "key.json" = stackit_service_account_key.myapp.json
    }
  }

Approaches for giving cluster workloads access to STACKIT services:

  Option A - SA Key as K8s Secret (simplest, good for POC):
    - Create service account + key via Terraform
    - Store key.json as a Kubernetes Secret
    - Mount the secret into pods that need STACKIT API access
    - Downside: static credentials, must rotate manually (or via rotate_when_changed)

  Option B - SA Key + External Secrets Operator (better):
    - Store the SA key in STACKIT Secret Manager
    - ESO syncs it into a K8s Secret automatically
    - Rotation is handled by updating the secret in Secret Manager
    - Pods still consume a regular K8s Secret

  Option C - Workload Identity Federation (keyless, recommended for production):
    - No static credentials stored anywhere
    - Uses stackit_service_account_federated_identity_provider
    - SKE cluster acts as an OIDC issuer
    - Pods exchange their projected ServiceAccount token at STACKIT STS
      (sts.accounts.stackit.cloud) for a short-lived STACKIT token
    - Flow:
        Pod (projected SA token)
          -> STACKIT STS token exchange
          -> Short-lived STACKIT token for the service account
          -> Call STACKIT APIs
    - Terraform setup:
        resource "stackit_service_account_federated_identity_provider" "myapp" {
          project_id            = var.project_id
          service_account_email = stackit_service_account.myapp.email
          name                  = "ske-myapp"
          issuer                = "<SKE cluster OIDC issuer URL>"
          assertions = [
            { item = "aud", operator = "equals", value = "sts.accounts.stackit.cloud" },
            { item = "sub", operator = "equals", value = "system:serviceaccount:<namespace>:<sa-name>" }
          ]
        }
    - The OIDC issuer URL for your SKE cluster can be found via:
        kubectl get --raw /.well-known/openid-configuration | jq .issuer

  Summary:
    Option   Credentials   Complexity   Best for
    ------   -----------   ----------   --------
    A        Static key    Low          POC / quick start
    B        Static key    Medium       Teams using ESO already
    C        Keyless       Higher       Production workloads


EXPERIMENTS
-----------
This section documents manual experiments and tests performed on the cluster,
outside of Terraform. These are not managed by Terraform and are for POC/testing purposes only.


EXPERIMENT 1 - ArgoCD
----------------------
Installed ArgoCD manually via Helm to test GitOps-style deployments on the SKE cluster.

Installation:
  helm repo add argo https://argoproj.github.io/argo-helm
  helm repo update
  helm install argocd argo/argo-cd --namespace argocd --create-namespace

Get initial admin password:
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

Access the UI (port-forward, no Ingress configured yet):
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  Open: https://localhost:8080
  Username: admin
  Password: (from command above)

NOTE: This is a default installation with no custom values. No Ingress, no TLS,
      no SSO, no HA. Suitable for POC only.

Expose ArgoCD via LoadBalancer (access via IP, no domain needed):
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

  Wait for STACKIT to provision the load balancer and assign a public IP:
  kubectl get svc argocd-server -n argocd -w

  Once EXTERNAL-IP is populated, open https://<external-ip> in your browser.
  Accept the self-signed certificate warning.
  Username: admin
  Password: (from command above)

Next steps for production ArgoCD:
  - Install nginx-ingress + cert-manager for proper HTTPS access
  - Configure Ingress with TLS (Let's Encrypt via cert-manager)
  - Set up SSO (Dex + OIDC provider)
  - Use HA mode (argocd-redis-ha, multiple replicas)
  - Manage ArgoCD itself via Terraform (helm_release resource)


REFERENCES
----------
- STACKIT Portal:            https://portal.stackit.cloud
- Terraform Provider Docs:   https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs
- Provider GitHub:           https://github.com/stackitcloud/terraform-provider-stackit
- STACKIT CLI:               https://github.com/stackitcloud/stackit-cli
- Terraform Install:         https://developer.hashicorp.com/terraform/install

