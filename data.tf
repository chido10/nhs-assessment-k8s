# -----------------------------------------------------------------------------
# File: terraform/data-availability-zones.tf
# Purpose: Retrieves the list of AWS Availability Zones in the region for
#          subnet and AZ-based resource distribution. Ensures we dynamically
#          select healthy AZs rather than hard-coding values.
# -----------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"  # Filter to only zones that are currently available
}
