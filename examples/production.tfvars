# Production Example - High availability with multiple node pools

prefix   = "myapp"
location = "eastus"
env      = "prod"

# Production-grade configuration
kubernetes_version = "1.30.7"
sku_tier           = "Standard" # Standard tier for production SLA

# Larger network for production
vnet_address_space          = ["10.0.0.0/16"]
aks_subnet_address_prefixes = ["10.0.0.0/19"]
pe_subnet_address_prefixes  = ["10.0.32.0/24"]

# Production default node pool - system workloads
default_node_pool_vm_size   = "Standard_D4s_v3"
default_node_pool_min_count = 3 # Higher minimum for HA
default_node_pool_max_count = 6

# Multiple node pools for different workload types
node_pools = {
  # Production application workloads
  apps = {
    vm_size         = "Standard_D8s_v3" # 8 vCPUs, 32 GB RAM
    min_count       = 3
    max_count       = 10
    os_disk_size_gb = 256
    priority        = "Regular"
    eviction_policy = "Delete"
    spot_max_price  = "-1"
    node_labels = {
      "workload-type" = "application"
      "environment"   = "production"
    }
    node_taints = []
  },

  # Memory-intensive workloads (databases, caches)
  memory = {
    vm_size         = "Standard_E16s_v3" # 16 vCPUs, 128 GB RAM
    min_count       = 2
    max_count       = 5
    os_disk_size_gb = 512
    priority        = "Regular"
    eviction_policy = "Delete"
    spot_max_price  = "-1"
    node_labels = {
      "workload-type" = "memory-intensive"
    }
    node_taints = ["workload=memory:NoSchedule"]
  },

  # Spot instances for batch processing
  batch = {
    vm_size         = "Standard_D8s_v3"
    min_count       = 0
    max_count       = 10
    os_disk_size_gb = 128
    priority        = "Spot"
    eviction_policy = "Delete"
    spot_max_price  = "0.5"
    node_labels = {
      "kubernetes.azure.com/scalesetpriority" = "spot"
      "workload-type"                         = "batch"
    }
    node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
  }
}

tags = {
  Environment = "production"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}
