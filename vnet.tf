# Virtual Network Module Configuration
# This module deploys:
# - Virtual Network with custom address space
# - Separate subnets for AKS and private endpoints
# - Private DNS zone for AKS
module "network" {
  source = "./modules/network"
  private_aks = local.private_cluster_enabled
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  vnet_name           = local.vnet_name
  vnet_address_space  = local.vnet_address_space
  subnets             = local.subnets
  tags                = local.tags
  dns_zone_name       = local.dns_zone_name
}