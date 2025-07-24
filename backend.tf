terraform {
  required_version = ">=0.12.0"
  # Temporarily commented out for validation
  # backend "s3" {
  #   region  = "ap-south-1"
  #   profile = "default"
  #   key     = "terraformstatefile"
  #   bucket  = "eks-terra-s3"
  # }
}