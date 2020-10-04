module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "osas-vpc"
  cidr = var.cidr

  azs              = var.azs
  database_subnets = var.database_subnet_cidr
  private_subnets  = var.private_subnet_cidr
  public_subnets   = var.public_subnet_cidr

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_ipv6 = true

  public_dedicated_network_acl   = true
  database_dedicated_network_acl = true
  private_dedicated_network_acl = true


public_inbound_acl_rules = concat(
    local.network_acls["ssh_public"],
    local.network_acls["icmp_internal"],
    local.network_acls["public_web_inbound"],
    local.network_acls["public_default_inbound"]
  )
  
database_inbound_acl_rules = concat(
    local.network_acls["private_inbounds"],
    local.network_acls["private_default_inbound"],
    local.network_acls["icmp_internal"]
)

private_inbound_acl_rules = concat(
    local.network_acls["private_inbounds"],
    local.network_acls["private_default_inbound"],
    local.network_acls["icmp_internal"]
)

public_outbound_acl_rules = local.network_acls["default_outbound"]
database_outbound_acl_rules = local.network_acls["default_outbound"]
private_outbound_acl_rules = local.network_acls["default_outbound"]


tags = {
    Terraform   = "true"
    Environment = "osas-prod"
  }
}

locals {
  network_acls = {
    ssh_public = [
      {
        rule_number = 700
        protocol    = "tcp"
        rule_action = "allow"
        cidr_block  = "0.0.0.0/0"
        to_port     = 22
        from_port   = 22
      }
    ]
    
    private_inbounds= [
     {
        rule_number = 700
        protocol    = "tcp"
        rule_action = "allow"
        cidr_block  = var.cidr
        to_port     = 22
        from_port   = 22
      },
      {
        rule_number = 800
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = var.cidr
        to_port     = 1024
        from_port   = 65535

      }

    ]

    private_default_inbound =  [ 
      {
        rule_number = 900
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
        to_port     = 32768
        from_port   = 65535

      }
    ]


    icmp_internal = [
      {
        rule_number = 1000
        protocol    = "icmp"
        rule_action = "allow"
        icmp_type   = -1
        icmp_code   = -1
        cidr_block  = var.cidr

      }
    ]
    default_outbound = [

      {
        rule_number = 300
        rule_action = "allow"
        cidr_block  = "0.0.0.0/0"
        protocol    = -1

      }
    ],

    public_default_inbound = [
      {
        rule_number = 300
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
        from_port   = 1024
        to_port     = 65535

      }


    ]

    public_web_inbound = [
      {
        rule_number = 400
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
        to_port     = 80
        from_port   = 80

      },
      {
        rule_number = 500
        rule_action = "allow"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
        to_port     = 443
        from_port   = 443

      }

    ]
  }
}