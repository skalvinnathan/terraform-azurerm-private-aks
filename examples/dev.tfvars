# Development Example - Cost-optimized configuration

prefix   = "myapp"
location = "eastus"
env      = "dev"

# Cost-effective settings for development
sku_tier = "Free"

# Smaller network for dev
vnet_address_space          = ["10.100.0.0/16"]
aks_subnet_address_prefixes = ["10.100.0.0/20"]
pe_subnet_address_prefixes  = ["10.100.16.0/24"]

# Minimal default node pool
default_node_pool_vm_size   = "Standard_B2s" # Burstable for cost savings
default_node_pool_min_count = 1
default_node_pool_max_count = 3

# Single spot node pool for development workloads
node_pools = {
  dev = {
    vm_size         = "Standard_D2s_v3"
    min_count       = 0
    max_count       = 3
    os_disk_size_gb = 128
    priority        = "Spot"
    eviction_policy = "Delete"
    spot_max_price  = "-1" # -1 means use default/maximum price for the region
    node_labels = {
      "kubernetes.azure.com/scalesetpriority" = "spot"
      "environment"                           = "development"
    }
    node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
  }
}

tags = {
  Environment  = "development"
  ManagedBy    = "Terraform"
  AutoShutdown = "enabled" # Can be used for automation
}
