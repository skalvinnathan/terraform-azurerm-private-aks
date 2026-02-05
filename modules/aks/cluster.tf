# AKS Cluster
# Private AKS cluster with advanced networking and security features
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.aks_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.aks_name
  private_cluster_enabled = var.private_cluster_enabled # Enable private cluster
  kubernetes_version      = var.kubernetes_version      # Kubernetes version
  private_dns_zone_id     = var.private_dns_zone_id

  # System node pool configuration
  default_node_pool {
    name                = var.aks_config.default_node_pool.name
    vm_size             = var.aks_config.default_node_pool.vm_size
    type                = var.aks_config.default_node_pool.type
    max_pods            = var.aks_config.default_node_pool.max_pods
    vnet_subnet_id      = var.subnet_id
    enable_auto_scaling = var.aks_config.default_node_pool.enable_auto_scaling
    max_count           = var.aks_config.default_node_pool.max_count
    min_count           = var.aks_config.default_node_pool.min_count
  }

  # Use user-assigned managed identity
  identity {
    type         = var.private_cluster_enabled ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.private_cluster_enabled ? [azurerm_user_assigned_identity.aks_identity[0].id] : []
  }

  # Network configuration
  network_profile {
    network_plugin    = var.aks_config.network_plugin
    network_policy    = var.aks_config.network_policy
    service_cidr      = var.aks_config.service_cidr
    dns_service_ip    = var.aks_config.dns_service_ip
    load_balancer_sku = "standard"
  }

  private_cluster_public_fqdn_enabled = false

  tags = var.tags
}