#============================================
# Variables to be used for the network module
#============================================

# Variable for the CIDR BLOCK to be used for the VPC
variable "cidr_block" {
  type        = string
  description = "Networking CIDR block to be used for the VPC"
}

# Variable for the project name
variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

# Variable for the tags
variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}