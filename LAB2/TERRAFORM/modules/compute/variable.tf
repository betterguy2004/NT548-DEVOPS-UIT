variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}
variable "key_name" {
  type = string
  description = "name of the keypair to use for the instance"
  nullable = false
}
variable "instance_type" {
  type        = string
  description = "Type of EC2 instance to launch. Example: t2.micro"
  default = "t3.micro"
}

variable "public_subnet_id" {
  type        = string
  description = "The subnet ID for the public instance"
  nullable    = false
}

variable "private_subnet_id" {
  type        = string
  description = "The subnet ID for the private instance"
  nullable    = false
}

variable "public_ec2_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for the public instance"
  nullable    = false
}

variable "private_ec2_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for the private instance"
  nullable    = false
}
