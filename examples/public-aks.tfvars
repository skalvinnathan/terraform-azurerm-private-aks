# Public AKS Cluster Configuration
# This creates a public AKS cluster with accessible API server

prefix   = "myapp"
location = "eastus"
env      = "dev"

# Disable private cluster (make it public)
private_cluster_enabled = false

kubernetes_version = "1.30.7"
sku_tier           = "Free" # Free tier for development

# Network configuration
vnet_address_space          = ["10.100.0.0/16"]
aks_subnet_address_prefixes = ["10.100.0.0/19"]
pe_subnet_address_prefixes  = ["10.100.32.0/24"] # Optional for public clusters (subnet not created)

# AKS configuration
service_cidr   = "172.16.0.0/16"
dns_service_ip = "172.16.0.10"
network_plugin = "azure"
network_policy = "azure"

# Default node pool - smaller for dev
default_node_pool_vm_size   = "Standard_D2s_v3"
default_node_pool_min_count = 1
default_node_pool_max_count = 3

# No additional node pools for simple public cluster
node_pools = {}

tags = {
  Environment = "development"
  ClusterType = "public"
  ManagedBy   = "Terraform"
}
