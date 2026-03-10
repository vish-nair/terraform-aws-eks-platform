variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "datadog_api_key_secret_arn" {
  description = "ARN of Secrets Manager secret containing the Datadog API key"
  type        = string
  default     = ""
}

variable "datadog_agent_version" {
  description = "Datadog agent Helm chart version"
  type        = string
  default     = "3.69.0"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
