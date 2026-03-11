variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "6.7.3"
}

variable "argocd_hostname" {
  description = "Hostname for ArgoCD UI (used for ingress/routing)"
  type        = string
  default     = ""
}

variable "enable_ha" {
  description = "Enable Redis HA mode for production-grade ArgoCD"
  type        = bool
  default     = false
}

variable "insecure_mode" {
  description = "Run ArgoCD server in insecure mode (HTTP). Set to true only when TLS is terminated upstream by an ingress/load balancer."
  type        = bool
  default     = false
}
