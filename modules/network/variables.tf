variable "project_id" {
  description = "GCP project ID where network resources will be created."
  type        = string
}

variable "region" {
  description = "GCP region for the subnet and router."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for all resource names (e.g. 'mlops' produces 'mlops-vpc')."
  type        = string
  default     = "mlops"
}

variable "subnet_cidr" {
  description = "CIDR range for the regional subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "labels" {
  description = "Labels to apply to resources that support them."
  type        = map(string)
  default     = {}
}
