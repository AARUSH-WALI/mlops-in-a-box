# Network Module

Creates a VPC network with Private Google Access, firewall rules, Cloud Router, and Cloud NAT — designed for secure ML workloads that run without public IP addresses.

## Architecture

- **Custom-mode VPC** with a single regional subnet
- **Private Google Access** enabled so VMs can reach Google APIs without external IPs
- **Cloud NAT** for outbound internet (e.g. pulling container images)
- **Firewall rules**: deny-all-ingress baseline, allow internal traffic, allow GCP health checks
- **VPC Flow Logs** at low sampling (10%) for cost-effective debugging

## Usage

```hcl
module "network" {
  source = "./modules/network"

  project_id  = "my-gcp-project"
  region      = "us-central1"
  name_prefix = "mlops"
  subnet_cidr = "10.0.0.0/24"

  labels = {
    environment = "dev"
    team        = "ml-platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP project ID where network resources will be created. | `string` | — | yes |
| `region` | GCP region for the subnet and router. | `string` | — | yes |
| `name_prefix` | Prefix for all resource names (e.g. `mlops` produces `mlops-vpc`). | `string` | `"mlops"` | no |
| `subnet_cidr` | CIDR range for the regional subnet. | `string` | `"10.0.0.0/24"` | no |
| `labels` | Labels to apply to resources that support them. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `network_id` | The ID of the VPC network. |
| `network_name` | The name of the VPC network. |
| `network_self_link` | The self link of the VPC network. |
| `subnet_id` | The ID of the regional subnet. |
| `subnet_name` | The name of the regional subnet. |
| `subnet_self_link` | The self link of the regional subnet. |
| `router_name` | The name of the Cloud Router. |
