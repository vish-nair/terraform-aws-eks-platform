variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "node_instance_types" {
  description = "List of instance types for Karpenter node pools"
  type        = list(string)
  default     = ["m5.large", "m5.xlarge", "m5a.large", "m5a.xlarge"]
}

variable "enable_datadog" {
  description = "Deploy Datadog agent via Helm"
  type        = bool
  default     = true
}

variable "datadog_api_key_secret_arn" {
  description = "ARN of Secrets Manager secret containing Datadog API key"
  type        = string
  default     = ""
}

variable "enable_argocd" {
  description = "Deploy ArgoCD via Helm"
  type        = bool
  default     = true
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "6.7.3"
}

variable "datadog_agent_version" {
  description = "Datadog agent Helm chart version"
  type        = string
  default     = "3.69.0"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
