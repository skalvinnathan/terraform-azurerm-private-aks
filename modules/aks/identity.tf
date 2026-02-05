# User-assigned managed identity for AKS
# This identity will be used by AKS to manage cluster resources
resource "azurerm_user_assigned_identity" "aks_identity" {
  count               = var.private_cluster_enabled ? 1 : 0
  name                = var.aks_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Assign Private DNS Zone Contributor role to AKS identity
# This allows AKS to manage DNS records in the private DNS zone
resource "azurerm_role_assignment" "aks_identity_dns" {
  count                = var.private_cluster_enabled ? 1 : 0
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity[count.index].principal_id
}