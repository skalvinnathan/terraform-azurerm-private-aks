# AKS Module Configuration
# This module deploys a private AKS cluster with:
# - User-assigned managed identity
# - Azure CNI networking
# - Network policies
# - Autoscaling enabled
module "aks" {
  source = "./modules/aks"

  resource_group_name     = azurerm_resource_group.rg.name
  location                = local.location
  aks_name                = local.aks_name
  aks_config              = local.aks_config
  subnet_id               = module.network.aks_subnet_id
  private_dns_zone_id     = module.network.private_dns_zone_id
  tags                    = local.tags
  kubernetes_version      = local.kubernetes_version
  private_cluster_enabled = local.private_cluster_enabled
}

module "node" {
  source                = "./modules/aks-node-pool"
  orchestrator_version  = local.kubernetes_version
  kubernetes_cluster_id = module.aks.cluster_id
  resource_group_name   = azurerm_resource_group.rg.name
  vnet_subnet_id        = module.network.aks_subnet_id

  node_pools = {
    for nodepool_key, nodepool in local.node_pools : nodepool.nodepool_name => {
      vm_size             = nodepool.vm_size
      priority            = nodepool.priority
      eviction_policy     = nodepool.eviction_policy
      location            = local.location
      enable_auto_scaling = true
      os_disk_size_gb     = nodepool.os_disk_size_gb
      os_disk_type        = "Managed"
      node_count          = 0
      min_count           = nodepool.min_count
      max_count           = nodepool.max_count
      max_pods            = 110
      node_labels         = nodepool.node_labels
      node_taints         = nodepool.node_taints
      spot_max_price      = nodepool.spot_max_price
    } if nodepool.create_nodepool
  }
}