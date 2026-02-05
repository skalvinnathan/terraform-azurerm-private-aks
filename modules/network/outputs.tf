output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "pe_subnet_id" {
  value = azurerm_subnet.pe_subnet.id
}

output "private_dns_zone_id" {
  value = var.private_aks ? azurerm_private_dns_zone.aks[0].id : null
}