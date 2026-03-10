# terraform-aws-eks-platform

A production-grade Terraform module that provisions a complete AWS EKS platform with Karpenter autoscaling, Datadog observability, and ArgoCD GitOps — all wired up and ready to run.

## Architecture

```
VPC (multi-AZ, public + private subnets)
└── EKS Cluster (1.30)
    ├── System Node Group (managed, m5.large x2) — taints: CriticalAddonsOnly
    ├── Karpenter (Spot + On-Demand, NodePool + EC2NodeClass)
    │   └── SQS Interruption Queue + EventBridge rules
    ├── Datadog Agent (DaemonSet, IRSA, logs + APM + metrics)
    └── ArgoCD (HA-ready, cluster agent)
```

## Features

- **VPC** — Multi-AZ with public/private subnets, NAT gateways, and proper EKS/Karpenter subnet tagging
- **EKS** — Managed cluster with OIDC provider for IRSA, control plane logging, and EKS add-ons (CoreDNS, kube-proxy, VPC CNI, Pod Identity)
- **Karpenter** — Dynamic node autoscaling with Spot support, SQS interruption handling, and consolidation policies
- **Datadog** — Agent deployed via Helm with IRSA, APM, log collection, and Cluster Agent for metrics
- **ArgoCD** — GitOps controller with HA-ready config and ApplicationSet support
- **CI/CD** — GitHub Actions workflow with OIDC auth, `plan` on PR, `apply` on merge to main

## Usage

```hcl
module "eks_platform" {
  source = "github.com/vishnunair/terraform-aws-eks-platform"

  cluster_name    = "my-cluster"
  cluster_version = "1.30"
  region          = "us-west-2"

  node_instance_types = ["m5.large", "m5.xlarge", "m5a.large"]

  enable_datadog             = true
  datadog_api_key_secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:datadog/api-key"

  enable_argocd = true

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `cluster_name` | EKS cluster name | `string` | — | yes |
| `cluster_version` | Kubernetes version | `string` | `"1.30"` | no |
| `region` | AWS region | `string` | `"us-west-2"` | no |
| `vpc_cidr` | VPC CIDR block | `string` | `"10.0.0.0/16"` | no |
| `availability_zones` | List of AZs | `list(string)` | 3 AZs in us-west-2 | no |
| `private_subnet_cidrs` | Private subnet CIDRs | `list(string)` | see variables.tf | no |
| `public_subnet_cidrs` | Public subnet CIDRs | `list(string)` | see variables.tf | no |
| `node_instance_types` | Instance types for Karpenter | `list(string)` | m5 family | no |
| `enable_datadog` | Deploy Datadog agent | `bool` | `true` | no |
| `datadog_api_key_secret_arn` | Secrets Manager ARN for Datadog API key | `string` | `""` | no |
| `enable_argocd` | Deploy ArgoCD | `bool` | `true` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | API server endpoint |
| `vpc_id` | VPC ID |
| `private_subnet_ids` | Private subnet IDs |
| `karpenter_irsa_role_arn` | Karpenter controller IAM role |
| `karpenter_node_role_arn` | Karpenter node IAM role |
| `oidc_provider_arn` | OIDC provider ARN |

## Prerequisites

- Terraform >= 1.5.0
- AWS credentials with sufficient IAM permissions
- S3 bucket + DynamoDB table for remote state (see `examples/complete/versions.tf`)

## Remote State Setup

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket your-terraform-state-bucket \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2

aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2
```

## Deploy

```bash
cd examples/complete
terraform init
terraform plan
terraform apply
```

## Author

**Vishnu V Nair** — Senior DevOps / Platform Engineer
CKA | HashiCorp Terraform Associate
[vishnair.com](https://vishnair.com) · [hello@vishnair.com](mailto:hello@vishnair.com)
