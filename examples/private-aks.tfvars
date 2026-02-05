# Private AKS Cluster Configuration
# This creates a fully private AKS cluster with no public endpoints

prefix   = "myapp"
location = "eastus"
env      = "prod"

# Enable private cluster
private_cluster_enabled = true

kubernetes_version = "1.30.7"
sku_tier           = "Standard" # Standard tier for production SLA

# Network configuration
vnet_address_space          = ["10.0.0.0/16"]
aks_subnet_address_prefixes = ["10.0.0.0/19"]
pe_subnet_address_prefixes  = ["10.0.32.0/24"]

# AKS configuration
service_cidr   = "172.16.0.0/16"
dns_service_ip = "172.16.0.10"
network_plugin = "azure"
network_policy = "azure"

# Default node pool
default_node_pool_vm_size   = "Standard_D4s_v3"
default_node_pool_min_count = 3 # Higher minimum for HA
default_node_pool_max_count = 6

# Additional node pools
node_pools = {
  apps = {
    vm_size         = "Standard_D8s_v3"
    min_count       = 2
    max_count       = 10
    os_disk_size_gb = 256
    priority        = "Regular"
    eviction_policy = "Delete"
    spot_max_price  = "-1"
    node_labels = {
      "workload-type" = "application"
    }
    node_taints = []
  }
}

tags = {
  Environment = "production"
  ClusterType = "private"
  ManagedBy   = "Terraform"
}
