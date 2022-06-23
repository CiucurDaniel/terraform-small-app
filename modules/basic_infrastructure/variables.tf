variable "aws_access_key" {
  default = "HIDE"
}

variable "aws_secrect_key" {
  default = "HIDE"
}

variable "stage" {
  default = "dev"
}

variable "general_cidr_block" {
  default     = "10.0.0.0/24"
  description = "The module creates a VPC with a single subnet, so VPC CIDR will be the same as Subnet CIDR"
}

variable "server_port" {
  default     = 8080
  description = "Server port to be used"
}

variable "ami_id" {
  default     = "ami-0cff7528ff583bf9a"
  description = "The ami you want to use for the EC2 instance"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "The EC2 instance type you want to use: t2.micro, t2.medium"
}
