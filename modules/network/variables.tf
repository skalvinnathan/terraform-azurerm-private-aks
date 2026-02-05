variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "Map of subnet configurations"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}

variable "dns_zone_name" {
  type        = string
  description = "Azure dns_zone_name "
}

variable "private_aks" {
  type        = bool
  description = "Azure private_aks"
}