variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "existing_instance_name" {
  description = "The name tag of the existing EC2 instance to use as a template"
  type        = string
}

variable "allowed_inbound_cidr_blocks" {
    description = "List of CIDR blocks to allow inbound traffic"
    type        = list(string)
}

variable "key_name" {
    description = "Name of the SSH key pair to use for the EC2 instance"
    type        = string
}

variable "existing_vpc_name" {
    description = "The name tag of the existing VPC to use as a template"
    type        = string
}

variable "existing_security_group_name" {
    description = "The name tag of the existing security group to use as a template"
    type        = string
}