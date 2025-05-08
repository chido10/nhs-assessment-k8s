# -----------------------------------------------------------------------------
# File: terraform/eks.tf
# Purpose: Provisions an EKS cluster, configures control-plane access,
#          sets up two managed node groups, and maps the IAM user
#          for cluster administration via AWS Access Entries API.
# -----------------------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"  # Official AWS EKS module
  version = "~> 20.36.0"                    # Pin to a stable module version

  # ---------------------------
  # Cluster Identity and Version
  # ---------------------------
  cluster_name    = "nhs-patient-monitoring"  # Unique name for the EKS cluster
  cluster_version = "1.27"                   # Kubernetes version

  # ---------------------------
  # Networking Configuration
  # ---------------------------
  vpc_id     = module.vpc.vpc_id               # VPC to host the cluster
  subnet_ids = module.vpc.private_subnets      # Private subnets for worker nodes

  # Public/private control-plane access
  cluster_endpoint_public_access  = true       # Allow public API server access
  cluster_endpoint_private_access = false      # Disable private-only access
  # Defaults to 0.0.0.0/0 for public if cidrs not specified

  # ---------------------------
  # Authentication and IAM Mapping
  # ---------------------------
  authentication_mode = "API_AND_CONFIG_MAP"  # Enable AWS IAM and kubeconfig auth

  # Map IAM user "doodoo" with admin policy to the cluster
  access_entries = {
    doodoo = {
      principal_arn = "arn:aws:iam::375630861224:user/doodoo"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }  # Grant full cluster admin
        }
      }
    }
  }

  # ---------------------------
  # Control-plane Logging
  # ---------------------------
  create_cloudwatch_log_group = true          # Enable CloudWatch log group
  cluster_enabled_log_types   = [             # Select log types for EKS control-plane
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  # ---------------------------
  # Managed Node Groups
  # ---------------------------
  eks_managed_node_groups = {
    ng-1 = {
      desired_capacity = 2     # Desired number of EC2 nodes
      min_capacity     = 2     # Minimum nodes
      max_capacity     = 2     # Maximum nodes
      instance_types   = ["t3.medium"]  # EC2 instance type
      disk_size        = 20    # EBS root volume size (GiB)
      subnet_ids       = module.vpc.private_subnets
      ssh              = { allow = false }  # Disable SSH for security
    }
    ng-2 = {
      desired_capacity = 2
      min_capacity     = 2
      max_capacity     = 2
      instance_types   = ["t3.medium"]
      disk_size        = 20
      subnet_ids       = module.vpc.private_subnets
      ssh              = { allow = false }
    }
  }

  # ---------------------------
  # Resource Tagging
  # ---------------------------
  tags = {
    Project     = "nhs-patient-monitoring"  # Project identifier
    Environment = "dev"                     # Deployment environment
    Owner       = "chido"                   # Resource owner tag
  }
}
