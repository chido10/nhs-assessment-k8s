# -----------------------------------------------------------------------------
# File: terraform/k8s-resources.tf
# Purpose: Defines Kubernetes namespace and Secret for the patient monitoring app.
#          This ensures isolation for our resources and secure password injection
#          for the PostgreSQL database using the randomly generated credential.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 1. Namespace Definition
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "patient_monitoring" {
  metadata {
    name = "patient-monitoring"  # Namespace isolates our application resources
    labels = {
      name = "patient-monitoring"  # Helps with selection via labels
    }
  }
}

# -----------------------------------------------------------------------------
# 2. Postgres Secret
# -----------------------------------------------------------------------------
resource "kubernetes_secret" "postgres_secrets" {
  metadata {
    name      = "postgres-secrets"                                  # Secret name used by pods
    namespace = kubernetes_namespace.patient_monitoring.metadata[0].name  # Place secret in our namespace
  }

  # Store the password as base64-encoded data (required by provider)
  data = {
    "postgres-password" = base64encode(random_password.db_password.result)
  }

  type = "Opaque"  # Standard Kubernetes secret type for arbitrary key-value pairs
}
