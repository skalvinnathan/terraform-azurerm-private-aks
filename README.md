# Private AKS Cluster with Terraform

This Terraform project deploys a private Azure Kubernetes Service (AKS) cluster with advanced networking features and security controls.

## Architecture Overview

- Private AKS cluster with no public endpoints
- Azure CNI networking with custom VNet and subnets
- User-assigned managed identity for cluster operations
- Private DNS zone for internal name resolution
- Network security with Azure Network Policy

## Prerequisites

- Azure subscription
- Azure CLI installed
- Terraform >= 1.0
- Access to a jumpbox/bastion host in the same VNet (for cluster access)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd terraform-azurerm-private-aks
   ```

2. **Create your variables file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Customize the variables**
   Edit `terraform.tfvars` with your desired configuration:
   ```hcl
   prefix   = "myproject"
   location = "eastus"
   env      = "prod"
   # ... customize other values
   ```

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Plan the deployment**
   ```bash
   terraform plan
   ```

6. **Apply the configuration**
   ```bash
   terraform apply
   ```

## Configuration

All configuration is managed through variables. You can customize the deployment by:

1. **Using terraform.tfvars** (recommended):
   ```hcl
   prefix   = "myaks"
   location = "westus2"
   env      = "prod"
   ```

2. **Using command line**:
   ```bash
   terraform apply -var="prefix=myaks" -var="env=prod"
   ```

3. **Using environment variables**:
   ```bash
   export TF_VAR_prefix="myaks"
   export TF_VAR_env="prod"
   terraform apply
   ```

### Key Variables

#### Required Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `prefix` | Prefix for resource naming | `"myapp"` |
| `location` | Azure region | `"eastus"` |
| `env` | Environment name | `"prod"` |

#### Optional Variables (with defaults)
| Variable | Description | Default |
|----------|-------------|---------|
| `kubernetes_version` | Kubernetes version | `"1.30.7"` |
| `private_cluster_enabled` | Enable private cluster | `true` |
| `vnet_address_space` | VNet CIDR blocks | `["10.172.0.0/18"]` |
| `sku_tier` | AKS SKU tier | `"Free"` |
| `network_plugin` | Network plugin | `"azure"` |
| `node_pools` | Additional node pools | `{}` (none) |

See `variables.tf` for the complete list of configurable variables.

### Node Pools

This module supports dynamic node pools. You can define multiple custom node pools in your `terraform.tfvars`:

```hcl
node_pools = {
  # Spot instances for cost-effective batch workloads
  spot = {
    vm_size         = "Standard_D4s_v4"
    min_count       = 0
    max_count       = 4
    os_disk_size_gb = 125
    priority        = "Spot"
    eviction_policy = "Delete"
    spot_max_price  = "0.3"
    node_labels = {
      "workload-type" = "batch"
    }
    node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
  },

  # Regular nodes for production workloads
  production = {
    vm_size         = "Standard_D8s_v3"
    min_count       = 2
    max_count       = 5
    os_disk_size_gb = 256
    priority        = "Regular"
    eviction_policy = "Delete"
    spot_max_price  = "-1"
    node_labels = {
      "workload-type" = "production"
    }
    node_taints = []
  }
}
```

See `examples/` directory for more configuration examples:
- `examples/minimal.tfvars` - Minimal configuration
- `examples/dev.tfvars` - Development environment
- `examples/production.tfvars` - Production environment with multiple node pools

## Network Configuration

- VNet CIDR: 10.172.0.0/18
- AKS Subnet: 10.172.0.0/19
- Private Endpoints Subnet: 10.172.32.0/24
- Kubernetes Service CIDR: 172.16.0.0/16
- Kubernetes DNS Service IP: 172.16.0.10

## Accessing the Private AKS Cluster

Since this is a private cluster, you can access it only from within the VNet or connected networks. Here are the methods to access the cluster:

1. **Via Azure Bastion (Recommended)**:
   - Deploy Azure Bastion in the VNet
   - Connect to a jumpbox VM in the VNet using Bastion
   - Install Azure CLI and kubectl on the jumpbox
   - Run `az aks get-credentials` to get cluster credentials

2. **Via VPN/ExpressRoute**:
   - Configure VPN or ExpressRoute connection to the VNet
   - Connect your local machine to the VPN
   - Use Azure CLI locally to access the cluster

3. **Via Command Invoke**:
   ```bash
   # Get cluster credentials
   az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>
   
   # Verify connection
   kubectl get nodes
   ```

## Security Features

- Private cluster with no public endpoints
- Azure Network Policy for network security
- RBAC enabled by default
- System-assigned managed identity
- Network security groups on subnets

## Scaling Configuration

- Autoscaling enabled: 1-3 nodes
- Node size: Standard_DS2_v2 (2 vCPUs, 7 GB memory)
- Maximum pods per node: 30

## Important Notes

1. Always use private endpoints for connecting to other Azure services
2. Keep the Kubernetes version updated
3. Monitor node and pod metrics for proper autoscaling
4. Regularly review and update network policies
5. Use Azure Key Vault for storing secrets (configure using CSI driver)

## Troubleshooting

1. **Cannot access cluster**:
   - Verify you're connected to the VNet
   - Check NSG rules
   - Verify Azure CLI credentials

2. **DNS resolution issues**:
   - Check private DNS zone links
   - Verify DNS service IP configuration

3. **Scaling issues**:
   - Check node resource usage
   - Verify autoscaling settings
   - Review pod resource requests/limits