provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

module "vpc" {
  source = "./modules/vpc"

  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  tags                 = var.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = var.tags
}

module "karpenter" {
  source = "./modules/karpenter"

  cluster_name        = module.eks.cluster_name
  cluster_endpoint    = module.eks.cluster_endpoint
  oidc_provider_arn   = module.eks.oidc_provider_arn
  node_instance_types = var.node_instance_types
  private_subnet_ids  = module.vpc.private_subnet_ids
  tags                = var.tags

  depends_on = [module.eks]
}

module "datadog" {
  source = "./modules/datadog"
  count  = var.enable_datadog ? 1 : 0

  cluster_name               = module.eks.cluster_name
  datadog_api_key_secret_arn = var.datadog_api_key_secret_arn
  datadog_agent_version      = var.datadog_agent_version
  oidc_provider_arn          = module.eks.oidc_provider_arn

  depends_on = [module.eks]
}

module "argocd" {
  source = "./modules/argocd"
  count  = var.enable_argocd ? 1 : 0

  argocd_version = var.argocd_version

  depends_on = [module.eks]
}
