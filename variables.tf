variable "aws_region" {
  description = "The AWS region to deploy the EKS cluster"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "dk-aws-eks"
}

variable "node_group_instance_type" {
  description = "The instance type for the EKS managed node group"
  type        = string
  default     = "t3.medium"
}

variable "node_group_desired_size" {
  description = "The desired number of nodes in the EKS managed node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "The maximum number of nodes in the EKS managed node group"
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "The minimum number of nodes in the EKS managed node group"
  type        = number
  default     = 1
}

variable "availability_zones" {
  description = "A list of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
