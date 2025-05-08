# -----------------------------------------------------------------------------
# File: terraform/provider.tf
# Purpose: Configures Kubernetes and Helm providers to communicate with the EKS cluster.
#          Uses Terraform data sources to fetch cluster endpoint, CA cert, and authentication token.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 1. Fetch existing EKS cluster details
# -----------------------------------------------------------------------------
# Retrieves cluster endpoint URL and certificate authority data
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name  # EKS cluster created by the module
}

# Retrieves authentication token for the EKS cluster service account
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

# -----------------------------------------------------------------------------
# 2. Configure Kubernetes provider
# -----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )  # Decode base64-encoded CA cert for TLS
  token                  = data.aws_eks_cluster_auth.this.token  # Bearer token for authentication
}

# -----------------------------------------------------------------------------
# 3. Configure Helm provider
# -----------------------------------------------------------------------------
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
