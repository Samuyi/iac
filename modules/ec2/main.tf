data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


locals {
  user_data = <<EOF
 #!/bin/bash
 sudo apt update -y && sudo apt install nginx -y
 sudo systemctl start nginx
 sudo systemctl enable nginx
 echo "<html> <body>Hello!</body> </html>" | sudo tee -a /var/www/html/index.html
EOF
}




module "server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = var.name

  user_data              = local.user_data
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = var.security_groups
  subnet_id              = var.subnet_id

  tags = {
    Terraform   = "true"
    Environment = "osas-dev"
  }
}