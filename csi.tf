# -----------------------------------------------------------------------------
# File: terraform/csi.tf
# Purpose: Installs and configures the AWS EBS CSI Driver as an EKS add-on,
#          including the necessary IAM role and policies for CSI to manage
#          EBS volumes. Ensures dynamic provisioning of EBS volumes in the cluster.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 1. Deploy AWS EBS CSI Driver add-on
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = module.eks.cluster_name      # Target EKS cluster for the add-on
  addon_name   = "aws-ebs-csi-driver"       # AWS-managed CSI driver add-on name

  # Version omitted to let AWS choose a compatible default
  resolve_conflicts_on_create = "OVERWRITE"  # Overwrite existing add-on resources if conflicts
  resolve_conflicts_on_update = "OVERWRITE"  # Overwrite on updates to ensure consistency

  service_account_role_arn = aws_iam_role.ebs_csi.arn  # IAM role for the CSI controller

  # Ensure the EKS cluster and IAM role are ready before installing the add-on
  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.ebs_csi_attach
  ]
}

# -----------------------------------------------------------------------------
# 2. IAM Role for CSI Driver
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ebs_csi" {
  name               = "${module.eks.cluster_name}-ebs-csi-addon-role"  # Role name scoped to the cluster
  assume_role_policy = data.aws_iam_policy_document.ebs_assume.json       # Trust policy allowing CSI to assume this role
}

# -----------------------------------------------------------------------------
# 3. IAM Policy Document for Trust Relationships
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "ebs_assume" {
  # Allow EC2 service to assume this role
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }

  # Allow EKS service account via OIDC to assume this role for pod-based auth
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

# -----------------------------------------------------------------------------
# 4. Attach EBS CSI Driver IAM Policy
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi.name                                   # Attach to the CSI role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"  # AWS-managed policy for CSI operations
}
