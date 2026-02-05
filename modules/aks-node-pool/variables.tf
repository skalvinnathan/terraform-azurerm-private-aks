# Docs
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
variable "node_pools" {}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "westus"
}

variable "kubernetes_cluster_id" {
  type = string
}

variable "vnet_subnet_id" {
  type = string
}

variable "orchestrator_version" {
  description = "Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Any tags can be set"
  default     = {}
}

variable "vm_size" {
  type        = string
  description = "Provide the instance type for the nodepool"
  default     = "Standard_B16ms"
}

variable "min_count" {
  type        = number
  description = "Provide the minimum number of instances for this nodepool"
  default     = 0
}

variable "max_count" {
  type        = number
  description = "Provide the maximum number of instances for this nodepool"
  default     = 1
}

variable "node_count" {
  type        = number
  description = "Provide the default number of instances for this nodepool"
  default     = 0
}

variable "enabling_auto_scaling" {
  type        = bool
  description = "Provide the boolean value if the nodepool need to be autoscaled"
  default     = true
}

variable "max_pods" {
  type        = number
  description = "Provide the default number of pods for per instance for this nodepool"
  default     = 110
}