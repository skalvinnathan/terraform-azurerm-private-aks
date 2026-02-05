variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "aks_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Name of the AKS version"
}
variable "private_cluster_enabled" {
  type        = string
  description = "Name of the AKS version"
}


variable "aks_config" {
  type = object({
    service_cidr   = string
    dns_service_ip = string
    network_plugin = string
    network_policy = string
    sku_tier       = string
    default_node_pool = object({
      name                = string
      vm_size             = string
      type                = string
      max_pods            = number
      enable_auto_scaling = bool
      max_count           = number
      min_count           = number
    })
  })
  description = "AKS cluster configuration"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet for AKS"
}

variable "private_dns_zone_id" {
  type        = string
  description = "ID of the private DNS zone for AKS"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}