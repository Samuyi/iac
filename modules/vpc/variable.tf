variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "cidr" {
  type    = string
  default = "10.12.0.0/16"
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.12.0.0/20", "10.12.16.0/20", "10.12.32.0/20"]
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.12.48.0/20", "10.12.64.0/20", "10.12.80.0/20"]
}

variable "database_subnet_cidr" {
  type    = list(string)
  default = ["10.12.96.0/20", "10.12.112.0/20", "10.12.128.0/20"]
}