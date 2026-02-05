locals {
  # General naming convention
  prefix   = "pri"
  location = "eastus"
  env      = "qa"

  # Resource naming - Using consistent naming convention for all Azure resources
  resource_group_name = "${local.prefix}-${local.env}-rg"
  vnet_name           = "${local.prefix}-${local.env}-vnet"
  aks_name            = "${local.prefix}-${local.env}-aks"
  dns_zone_name       = "${local.prefix}.privatelink.${local.location}.azmk8s.io" # Private DNS zone for AKS
  identity_name       = "${local.prefix}-${local.env}-aks-identity"               # User-assigned managed identity
  kubernetes_version  = "1.30.7"
  private_cluster_enabled = true
  # Network configuration
  vnet_address_space = ["10.172.0.0/18"] # VNet CIDR: 10.172.0.0 - 10.172.63.255

  subnets = {
    aks = {
      name             = "aks-subnet"
      address_prefixes = ["10.172.0.0/19"] # AKS Subnet: 10.172.0.0 - 10.172.31.255
    }
    private_endpoints = {
      name             = "pe-subnet"
      address_prefixes = ["10.172.32.0/24"] # PE Subnet: 10.172.32.0 - 10.172.32.255
    }
  }

  # AKS specific configuration
  aks_config = {
    service_cidr   = "172.16.0.0/16" # Non-overlapping CIDR for Kubernetes services
    dns_service_ip = "172.16.0.10"   # Must be within service_cidr
    network_plugin = "azure"         # Use Azure CNI for advanced networking features
    network_policy = "azure"         # Azure Network Policy for network security
    sku_tier       = "Free"          # Standard tier for production workloads

    default_node_pool = {
      name                = "systempool"
      vm_size             = "Standard_DS2_v2"         # 2 vCPUs, 7 GB memory
      type                = "VirtualMachineScaleSets" # Use VMSS for better scaling
      enable_auto_scaling = true                      # Enable cluster autoscaling
      max_count           = 3                         # Maximum nodes when scaling up
      min_count           = 1                         # Minimum nodes when scaling down
      max_pods            = 110                        # Maximum pods per node
    }
  }

  # Node pool configurations
  node_pools = {
    # Configuration for the spot node pool
    spot_pool = {
      create_nodepool = false
      nodepool_name   = "spot"
      vm_size         = "Standard_D4s_v4" # VM size for the spot node pool
      priority        = "Spot" # Priority set to Spot for cost savings
      eviction_policy = "Delete" # Eviction policy for spot instances
      spot_max_price  = "0.3" # Maximum price for spot instances
      os_disk_size_gb = 125 # OS disk size in GB
      min_count       = 0 # Minimum number of nodes
      max_count       = 4 # Maximum number of nodes
      node_labels = {
        "kubernetes.azure.com/scalesetpriority" = "spot" # Label indicating spot priority
        "Project"                               = "qa" # Project label for QA environment
      }
      node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"] # Taint to prevent scheduling on spot nodes
    },
    # Configuration for the regular node pool
    regular_pool = {
      create_nodepool = false
      nodepool_name   = "regular"
      vm_size         = "Standard_D4s_v4" # VM size for the regular node pool
      priority        = "Regular" # Priority set to Regular
      eviction_policy = null # No eviction policy for regular instances
      spot_max_price  = null # No spot pricing for regular instances
      os_disk_size_gb = 125 # OS disk size in GB
      min_count       = 0 # Minimum number of nodes
      max_count       = 3 # Maximum number of nodes
      node_labels = {
        "Project" = "production" # Project label for production environment
      }
      node_taints = [] # No taints for regular nodes
    }
    # Add additional node pool configurations below by copying and modifying the spot or regular node pool configurations
  }

  # Tags to apply to resources
  tags = {
    Environment = local.env # Environment tag
    Terraform   = "true" # Tag indicating Terraform management
    Project     = "AKS" # Project tag
  }
}