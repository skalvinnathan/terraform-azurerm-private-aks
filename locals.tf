locals {
  # General naming convention - derived from variables
  prefix   = var.prefix
  location = var.location
  env      = var.env

  # Resource naming - Using consistent naming convention for all Azure resources
  resource_group_name     = "${local.prefix}-${local.env}-rg"
  vnet_name               = "${local.prefix}-${local.env}-vnet"
  aks_name                = "${local.prefix}-${local.env}-aks"
  dns_zone_name           = "${local.prefix}.privatelink.${local.location}.azmk8s.io" # Private DNS zone for AKS (only used if private)
  identity_name           = "${local.prefix}-${local.env}-aks-identity"               # User-assigned managed identity (only used if private)
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = var.private_cluster_enabled

  # Network configuration - derived from variables
  vnet_address_space = var.vnet_address_space

  subnets = {
    aks = {
      name             = "aks-subnet"
      address_prefixes = var.aks_subnet_address_prefixes
    }
    private_endpoints = {
      name             = "pe-subnet"
      address_prefixes = var.pe_subnet_address_prefixes
    }
  }

  # AKS specific configuration - derived from variables
  aks_config = {
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
    network_plugin = var.network_plugin
    network_policy = var.network_policy
    sku_tier       = var.sku_tier

    default_node_pool = {
      name                = var.default_node_pool_name
      vm_size             = var.default_node_pool_vm_size
      type                = "VirtualMachineScaleSets" # Use VMSS for better scaling
      enable_auto_scaling = var.default_node_pool_enable_auto_scaling
      max_count           = var.default_node_pool_max_count
      min_count           = var.default_node_pool_min_count
      max_pods            = var.default_node_pool_max_pods
    }
  }

  # Node pool configurations - dynamic, supports multiple custom node pools
  node_pools = {
    for pool_name, pool in var.node_pools : pool_name => {
      create_nodepool = true
      nodepool_name   = pool_name
      vm_size         = pool.vm_size
      priority        = pool.priority
      eviction_policy = pool.priority == "Spot" ? pool.eviction_policy : null
      spot_max_price  = pool.priority == "Spot" ? pool.spot_max_price : null
      os_disk_size_gb = pool.os_disk_size_gb
      min_count       = pool.min_count
      max_count       = pool.max_count
      node_labels     = pool.node_labels
      node_taints     = pool.node_taints
    }
  }

  # Tags to apply to resources - merge user-provided tags with defaults
  tags = merge(
    {
      Environment = local.env
      Terraform   = "true"
      Project     = "AKS"
    },
    var.tags
  )
}