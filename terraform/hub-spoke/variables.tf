variable "azure_region" {
  type        = string
  default     = "eastus"
  description = "Target Azure Region for Enterprise Hub & Spoke"
}

variable "tags" {
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "Mithilesh Yadav"
  }
}
