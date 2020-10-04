variable "instance_type" {
  description = "ec2 instance type"
  default     = "t2.small"
}

variable "key_name" {}

variable "name" {
  type   = string
}


variable "subnet_id" {}

variable "security_groups" {
  type = list(string)
}

