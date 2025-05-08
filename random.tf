# -----------------------------------------------------------------------------
# File: terraform/random_password.tf
# Purpose: Generates a secure, random password for the PostgreSQL database and
#          exposes it as a sensitive Terraform output. This avoids hard-coding
#          credentials and integrates with our infrastructure-as-code workflow.
# -----------------------------------------------------------------------------

# Generate a 16-character password with a mix of character types
resource "random_password" "db_password" {
  length           = 16                     # Total password length
  min_lower        = 1                      # At least 1 lowercase letter
  min_upper        = 1                      # At least 1 uppercase letter
  min_numeric      = 1                      # At least 1 digit
  min_special      = 1                      # At least 1 special character
  override_special = "!@#$%&*()-_=+[]{}<>?"  # Allowed set of special characters
}

# Output the generated password as a sensitive value
output "postgres_password" {
  value     = random_password.db_password.result  # The generated password from the resource
  sensitive = true                                  # Marks this output as sensitive to avoid unintended exposure
}
