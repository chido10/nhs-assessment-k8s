# -----------------------------------------------------------------------------
# File: terraform/k8s-storageclass.tf
# Purpose: Defines the default AWS EBS CSI StorageClass for dynamic volume provisioning
#          in the Kubernetes cluster. This StorageClass uses gp3 volumes, ensures
#          volumes are bound only when pods are scheduled, and cleans up on deletion.
# -----------------------------------------------------------------------------

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"  # StorageClass name as referenced by PersistentVolumeClaims
    annotations = {
      # Mark this as the default StorageClass in the cluster
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  # Use the AWS EBS CSI driver for provisioning volumes
  storage_provisioner = "ebs.csi.aws.com"

  # When a PVC is deleted, automatically delete the underlying EBS volume
  reclaim_policy = "Delete"

  # Delay volume provisioning until a Pod is scheduled to a matching Node
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type   = "gp3"    # Use General Purpose SSD (gp3) EBS volume type
    fsType = "ext4"   # Filesystem type to format the volume
  }

  # Ensure the EBS CSI add-on is installed before creating the StorageClass
  depends_on = [
    aws_eks_addon.ebs_csi  # Reference to the EKS CSI add-on resource
  ]
}
