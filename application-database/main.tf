provider "aws" {
  region = "eu-west-1"

}

resource "aws_key_pair" "dev_access" {
  key_name   = "dev_access"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6XAypCKyKBiuAW4B0J+r2OktU8l5Ce+iU7Ho8UO2XFUt2sUUyTOLn5HViP5KRgj16KWWz5FdL1B0oxS4rJmcTJm1yxAZFn5iTLHlFW6y7CYqdJlWtmnNNJKHH3WcxCDxJ0s/Wgiqdi36I1vbM+cuCRyUMeFhIui/RTf4UDmX4vgjSMlvqlG5eqEhDcX5NKTXKHbWM3wdkn6F6W9+GFclQVTVMZxZvO020pexkJzhL1hw8vt3QFzyWKeTnxI6xR9jO+vhx170xtd6t9l86ZLoW5UhdQX6uxot9cH/egonceKtJQMGXB74pYVLI3VFri6IIEJUyzaO1eXXeddBwc8+EV8r9jHhw3LraIVEQ+pJkn3ujZmbDZO0V5vYsMiyilQubR3Eg8KCSgltZ9acGh7d8hnW3GECaUIyQWqbz+wlmn4aXmYBzqW0aBLfdSYTfVt6FplGTgKAcU/Kh4HSrVXxnmRkiXnGyqq/ICxyjFn3jxJfgPzeKGh5NCbCGTa63x0cCLHmShrKEYWQM4zjj9juwZMG8xNh694ytSvQWHxWb6VChBJXlMROB8Ac3yebOH8MWM6nuYZs6XAtx7D6WKXJBHO2jtbOHxKBxx5ATf8dDYCJz9tqMIQRNe4H8aQ34l8uAT62mnQXNfpR/5FEytOO02DYaE6D475/2RxsKxKqFdw== samuyi@samuyi-ROG-Zephyrus-G15-GA502IV-GA502IV"

}

module "vpc" {
  source = "../modules/vpc"
}

module "http_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "http-allow"
  description = "Security group for web access"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}

module "icmp_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "icmp-allow"
  description = "Security group for web access"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "allow icmp within vpc"
      cidr_blocks = "10.12.0.0/16"
    }
  ]
}

module "ssh_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name                = "ssh-allow"
  description         = "Security group for ssh access"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
}

module "database_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name                = "ssh-allow"
  description         = "Security group for ssh access"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = [module.web-server.public_ip[0]]
  ingress_rules       = ["postgresql-tcp"]
}


module "web-server" {
  source          = "../modules/ec2"
  name            = var.name
  instance_type   = var.instance_type
  key_name        = aws_key_pair.dev_access.key_name
  subnet_id       = module.vpc.public_subnets[1]
  security_groups = [module.http_security_group.this_security_group_id, module.icmp_security_group.this_security_group_id, module.ssh_security_group.this_security_group_id]

}

module "database" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "osasdb-postgres"

  engine            = "postgres"
  engine_version    = "11.3"
  instance_class    = "t3.xlarge"
  allocated_storage = 5
  storage_encrypted = false

  name     = "osas-db"
  username = "osas"
  password = "hYSLov0U3+FA5l+L4I0jJb6pRuXqhIQ3F+TSk1"
  port     = "5432"

  vpc_security_group_ids = [module.database_security_group.this_security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 1

  subnet_ids =  module.vpc.database_subnets

  major_engine_version = "11"
}

module "replica" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "osasdb-replica-postgres"

  replicate_source_db = module.database.this_db_instance_id

  name     = "osas-db"
  port     = "5432"

  username = ""
  password = ""
  

  vpc_security_group_ids = [module.database_security_group.this_security_group_id]
  maintenance_window = "Tue:00:00-Tue:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

}