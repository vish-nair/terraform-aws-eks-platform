module "eks_platform" {
  source = "../../"

  cluster_name    = "my-eks-platform"
  cluster_version = "1.30"
  region          = "us-west-2"

  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  node_instance_types = ["m5.large", "m5.xlarge", "m5a.large", "m5a.xlarge"]

  enable_datadog             = true
  datadog_api_key_secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:datadog/api-key"

  enable_argocd = true

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}
