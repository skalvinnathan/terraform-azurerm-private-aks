# Virtual Network for AKS cluster
# This VNet will host the AKS cluster and related networking components
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Subnet for AKS nodes
# This subnet will host the AKS nodes and pods
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnets.aks.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnets.aks.address_prefixes

  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
}

# Subnet for Private Endpoints
# This subnet will host private endpoints for Azure services
resource "azurerm_subnet" "pe_subnet" {
  name                 = var.subnets.private_endpoints.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnets.private_endpoints.address_prefixes

  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
}