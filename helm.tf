# -----------------------------------------------------------------------------
# File: terraform/simplified-helm.tf
# Purpose: Deploys PostgreSQL into the EKS cluster using Terraform's Helm provider.
#          This simplified HelmRelease resource overrides only the essential
#          values to connect to our existing Secret, configure persistence,
#          resource constraints, and ensure a reliable, atomic install.
# -----------------------------------------------------------------------------

resource "helm_release" "postgres" {
  # Basic release identification
  name       = "postgres"                                    # Helm release name in the cluster
  repository = "https://charts.bitnami.com/bitnami"          # Helm chart repository URL
  chart      = "postgresql"                                  # Chart to deploy
  version    = "15.5.3"                                     # Pin to a stable chart version
  namespace  = kubernetes_namespace.patient_monitoring.metadata[0].name  # Deploy into our application namespace

  # ---------------------------
  # Configuration Overrides
  # ---------------------------
  set {
    name  = "auth.existingSecret"                           # Use the Kubernetes Secret for DB credentials
    value = kubernetes_secret.postgres_secrets.metadata[0].name
  }
  set {
    name  = "primary.persistence.size"                       # Define PVC size for DB data
    value = "5Gi"
  }
  set {
    name  = "primary.persistence.storageClass"              # Bind volumes to our gp3 StorageClass
    value = "gp3"
  }
  set {
    name  = "primary.resources.requests.cpu"                # Minimum CPU requested by the pod
    value = "100m"
  }
  set {
    name  = "primary.resources.requests.memory"             # Minimum memory requested by the pod
    value = "128Mi"
  }
  set {
    name  = "primary.resources.limits.cpu"                  # Maximum CPU limit for the container
    value = "200m"
  }
  set {
    name  = "primary.resources.limits.memory"               # Maximum memory limit for the container
    value = "256Mi"
  }

  # Stability and cleanup settings
  timeout = 1800    # Wait up to 30 minutes for resources to be ready
  wait    = true    # Block until all resources are in a ready state
  atomic  = true    # Roll back changes if the install or upgrade fails

  # Ensure dependencies are created before deploying the chart
  depends_on = [
    kubernetes_namespace.patient_monitoring,
    kubernetes_secret.postgres_secrets,
    aws_eks_addon.ebs_csi,
    kubernetes_storage_class.gp3,
    module.eks
  ]
}
