# Azure AKS Cluster with Terraform

This Terraform module deploys Azure Kubernetes Service (AKS) clusters with support for both **public** and **private** configurations, advanced networking features, and security controls.

## Features

✅ **Supports both Public and Private AKS clusters**
✅ **Dynamic node pools** - Add unlimited custom node pools (spot/regular)
✅ **Fully configurable** - All values via variables, no hardcoding
✅ **Azure CNI networking** - Custom VNet and subnets
✅ **Auto-scaling** - Node pool autoscaling support
✅ **Network policies** - Azure, Calico, or Cilium
✅ **Production-ready** - Validated configurations included

## Architecture Overview

### Private AKS (default)
- Private AKS cluster with no public endpoints
- User-assigned managed identity for cluster operations
- Private DNS zone for internal name resolution
- Requires VPN/Bastion for access

### Public AKS
- Public AKS cluster with internet-accessible API server
- System-assigned managed identity
- Direct kubectl access from anywhere
- Ideal for development/testing

## Prerequisites

- Azure subscription
- Azure CLI installed
- Terraform installed
- Access to a jumpbox/bastion host in the same VNet (for cluster access)

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
## Public vs Private Clusters

| Feature | Private Cluster | Public Cluster |
|---------|----------------|----------------|
| API Server | No public endpoint | Internet accessible |
| Identity | User-Assigned | System-Assigned |
| DNS Zone | Private DNS zone created | Not created |
| Access | Requires VPN/Bastion | Direct kubectl access |
| Use Case | Production, high security | Development, testing |
| Cost | Slightly higher | Lower |
| Configuration | `private_cluster_enabled = true` | `private_cluster_enabled = false` |

## Quick Examples

### Private AKS Cluster
```bash
terraform apply -var-file=examples/private-aks.tfvars
```

### Public AKS Cluster
```bash
terraform apply -var-file=examples/public-aks.tfvars
```

### Minimal Configuration
```hcl
# minimal.tfvars
prefix   = "myapp"
location = "eastus"
env      = "dev"
private_cluster_enabled = false  # Public cluster for easy access
node_pools = {}  # No additional node pools
```

