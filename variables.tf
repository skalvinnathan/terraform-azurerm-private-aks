# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "prefix" {
  type        = string
  description = "Prefix for resource naming convention"
}

variable "location" {
  type        = string
  description = "Azure region location for resources"
}

variable "env" {
  type        = string
  description = "Environment name (e.g., dev, qa, prod)"
}

# ==============================================================================
# AKS CLUSTER CONFIGURATION
# ==============================================================================

variable "private_cluster_enabled" {
  type        = bool
  description = "Enable private cluster (true) or public cluster (false)"
  default     = true
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for AKS cluster"
  default     = "1.30.7"
}

variable "sku_tier" {
  type        = string
  description = "SKU tier for AKS cluster (Free or Standard)"
  default     = "Free"
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "SKU tier must be either 'Free' or 'Standard'."
  }
}

# ==============================================================================
# NETWORK CONFIGURATION
# ==============================================================================

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
  default     = ["10.172.0.0/18"]
}

variable "aks_subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for AKS subnet"
  default     = ["10.172.0.0/19"]
}

variable "pe_subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for Private Endpoints subnet"
  default     = ["10.172.32.0/24"]
}

variable "service_cidr" {
  type        = string
  description = "CIDR for Kubernetes services (non-overlapping with VNet)"
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  type        = string
  description = "IP address for Kubernetes DNS service (must be within service_cidr)"
  default     = "172.16.0.10"
}

variable "network_plugin" {
  type        = string
  description = "Network plugin for AKS (azure or kubenet)"
  default     = "azure"
  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  type        = string
  description = "Network policy for AKS (azure, calico, or cilium)"
  default     = "azure"
  validation {
    condition     = contains(["azure", "calico", "cilium"], var.network_policy)
    error_message = "Network policy must be 'azure', 'calico', or 'cilium'."
  }
}

# ==============================================================================
# DEFAULT NODE POOL CONFIGURATION
# ==============================================================================

variable "default_node_pool_name" {
  type        = string
  description = "Name of the default node pool"
  default     = "systempool"
}

variable "default_node_pool_vm_size" {
  type        = string
  description = "VM size for default node pool"
  default     = "Standard_DS2_v2"
}

variable "default_node_pool_enable_auto_scaling" {
  type        = bool
  description = "Enable auto-scaling for default node pool"
  default     = true
}

variable "default_node_pool_min_count" {
  type        = number
  description = "Minimum node count for default node pool"
  default     = 1
}

variable "default_node_pool_max_count" {
  type        = number
  description = "Maximum node count for default node pool"
  default     = 3
}

variable "default_node_pool_max_pods" {
  type        = number
  description = "Maximum pods per node in default node pool"
  default     = 110
}

# ==============================================================================
# ADDITIONAL NODE POOLS
# ==============================================================================

variable "node_pools" {
  type = map(object({
    vm_size         = string
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    priority        = string       # "Regular" or "Spot"
    eviction_policy = string       # "Delete" or "Deallocate" (only for Spot)
    spot_max_price  = string       # "-1" for default/max price, or a positive number > 0.00001
    node_labels     = map(string)  # Custom labels for the node pool
    node_taints     = list(string) # Taints to apply to nodes
  }))
  description = "Map of additional node pools to create. For spot_max_price: use '-1' for default/maximum price, or specify a positive value (must be > 0.00001)."
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.node_pools : contains(["Regular", "Spot"], v.priority)
    ])
    error_message = "Node pool priority must be either 'Regular' or 'Spot'."
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      v.priority == "Spot" ? contains(["Delete", "Deallocate"], v.eviction_policy) : true
    ])
    error_message = "Spot node pools must have eviction_policy set to 'Delete' or 'Deallocate'."
  }

  validation {
    condition = alltrue([
      for k, v in var.node_pools :
      v.priority == "Spot" ? (v.spot_max_price == "-1" || tonumber(v.spot_max_price) > 0.00001) : true
    ])
    error_message = "Spot node pools must have spot_max_price set to '-1' (for default/max price) or a positive value greater than 0.00001."
  }
}

# ==============================================================================
# TAGS
# ==============================================================================

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
