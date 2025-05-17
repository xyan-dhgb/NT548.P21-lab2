# VPC consists of Public and Private Subnets, NAT Gateway, and Internet Gateway, Public and Private Route Table

# Create VPC
resource "aws_vpc" "main" {
    cidr_block              = var.vpc_cidr
    enable_dns_support      = true
    enable_dns_hostnames    = true
    tags = {
        Name = "VPC-${var.vpc_name}"
    }
}

# Create Public Subnet
# checkov:skip=CKV_AWS_130: Need default public IP for lab/demo
resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone       = var.az[0]
    tags = {
        Name = "PublicSubnet-${var.public_subnet_name}"
    }
}

# Create Private Subnet
resource "aws_subnet" "private" {
    vpc_id             = aws_vpc.main.id
    cidr_block         = var.private_subnet_cidr
    availability_zone  = var.az[1]
    tags = {
        Name = "PrivateSubnet-${var.private_subnet_name}"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "InternetGateway-${var.internet_gateway_name}"
    }
}

# Create Elastic IP (eip) for NAT Gateway
resource "aws_eip" "nat" {
    domain = "vpc"
    tags = {
        Name = "ElasticIP-${var.elastic_ip_for_nat}"
    }
}

# Create NAT Gateway
resource "aws_nat_gateway" "natgw" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public.id
    tags = {
        Name = "NATGateway-${var.nat_gateway_name}"
    }
}

# Create Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    tags = {
        Name = "PublicRouteTable-${var.public_route_table_name}"
    }
}

# Create Private Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
    }
    tags = {
        Name = "PrivateRouteTable-${var.private_route_table_name}"
    }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = []
    ipv6_cidr_blocks  = []
    security_groups   = []
    prefix_list_ids   = []
    description       = "Deny all inbound"
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = []
    ipv6_cidr_blocks  = []
    security_groups   = []
    prefix_list_ids   = []
    description       = "Deny all outbound"
  }

  tags = {
    Name = "Default SG - deny all"
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs/${aws_vpc.main.id}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.vpc_flow_logs.arn
}

resource "aws_flow_log" "vpc_flow_log" {
    log_destination_type = "cloud-watch-logs"
    log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
    iam_role_arn         = aws_iam_role.vpc_flow_log_role.arn
    vpc_id               = aws_vpc.main.id
    traffic_type         = "ALL"
}

resource "aws_iam_role" "vpc_flow_log_role" {
    name = "vpcFlowLogRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "vpc-flow-logs.amazonaws.com"
        }
        }]
    })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
    name = "vpcFlowLogPolicy"
    role = aws_iam_role.vpc_flow_log_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
            ]
            Resource = [
            "arn:aws:logs:${var.aws_regions}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs/${aws_vpc.main.id}:*"
            ]
            Condition = {
            "StringEquals" = {
                "aws:ResourceTag/Name" = "VPC Flow Logs"
            }
            }
        }]
        })
}

resource "aws_kms_key" "vpc_flow_logs" {
    description = "KMS key for VPC Flow Logs CloudWatch Log Group"

    policy = jsonencode({
        Version = "2012-10-17"
        Id      = "key-default-1"
        Statement = [
        {
            Sid       = "Allow administration of the key"
            Effect    = "Allow"
            Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action    = "kms:*"
            Resource  = "*"
        }
        ]
    })
}

data "aws_caller_identity" "current" {}