provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//vpc?ref=main"

  name               = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.internet_gateway_id
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_network_acl" "public" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  tags = {
    Name        = "${var.project_name}-public-nacl"
    Project     = var.project_name
    Environment = var.environment
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
}

module "web_security_group" {
  source = "git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//security-group?ref=main"

  name        = "${var.project_name}-web-sg"
  description = "Security group for web application access"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "ec2_app" {
  source = "git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//ec2?ref=main"

  name                        = "${var.project_name}-app"
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  security_group_ids          = [module.web_security_group.security_group_id]
  associate_public_ip_address = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-app"
  }
}
