variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "node_role_arn" {
  description = "Existing node IAM role ARN. Leave empty to create a new one."
  type        = string
  default     = ""
}

variable "node_instance_types" {
  description = "Instance types for Karpenter NodePool"
  type        = list(string)
  default     = ["m5.large", "m5.xlarge", "m5a.large", "m5a.xlarge"]
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Karpenter nodes"
  type        = list(string)
}

variable "karpenter_version" {
  description = "Karpenter Helm chart version"
  type        = string
  default     = "0.37.0"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
