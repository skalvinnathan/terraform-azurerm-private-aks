# Private DNS Zone for AKS
# Required for private AKS cluster to resolve internal endpoints
resource "azurerm_private_dns_zone" "aks" {
  count             = var.private_aks ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link the Private DNS Zone to the VNet
# This enables DNS resolution for AKS private endpoints
resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  count             = var.private_aks ? 1 : 0
  name                  = "aks-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks[count.index].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = var.tags
}