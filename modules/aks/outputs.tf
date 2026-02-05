output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "private_fqdn" {
  value = azurerm_kubernetes_cluster.aks.private_fqdn
}