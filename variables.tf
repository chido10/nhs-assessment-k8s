# -----------------------------------------------------------------------------
# File: terraform/variables.tf
# Purpose: Declares input variables for the AWS VPC and related infrastructure.
#          These variables allow customization of region and network addressing
#          without modifying the underlying Terraform modules directly.
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to deploy into (e.g., eu-west-2)"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the new VPC (e.g., 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}
