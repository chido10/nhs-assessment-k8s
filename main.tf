# -----------------------------------------------------------------------------
# File: terraform/main.tf
# Purpose: Configures Terraform and provider requirements for AWS, Kubernetes, and Helm.
#          Specifies minimum Terraform version and pins provider plugins to ensure
#          consistent, reproducible infrastructure deployments.
# -----------------------------------------------------------------------------

terraform {
  # Enforce Terraform version compatibility
  required_version = ">= 1.3.0"

  # Define provider dependencies and version constraints
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # AWS provider for managing AWS resources
      version = "~> 5.0"           # Allow any 5.x release
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"  # Kubernetes provider for managing k8s resources
      version = "~> 2.0"               # Allow any 2.x release
    }

    helm = {
      source  = "hashicorp/helm"       # Helm provider for deploying Helm charts
      version = "~> 2.0"               # Allow any 2.x release
    }
  }
}
