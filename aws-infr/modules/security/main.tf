#Create security groups for public EC2 instances
# checkov:skip=CKV_AWS_24: Need to open SSH for lab/demo
# checkov:skip=CKV2_AWS_5: This SG is already attached to EC2 via module
resource "aws_security_group" "public_ec2_sg" {
    name        = var.public_ec2_sg_name
    vpc_id      = var.vpc_id
    description = "Security group for public EC2 instances"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.allowed_ssh_cidr]
        description = "Allow SSH from trusted IP"
    }

    egress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP outbound"
    }

    egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound"
  }
}

# Create security groups for private EC2 instances
# checkov:skip=CKV2_AWS_5: This SG is already attached to EC2 via module
resource "aws_security_group" "private_ec2_sg" {
    name        = var.private_ec2_sg_name
    vpc_id      = var.vpc_id
    description = "Security group for private EC2 instances"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr_block]
        description = "Allow SSH from VPC"
    }
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr_block]
        description = "Allow HTTP from VPC"
    }

    ingress {
        from_port  = -1
        to_port    = -1
        protocol   = "icmp"
        cidr_blocks = [var.vpc_cidr_block]
        description = "Allow ICMP from VPC"
    }

    egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound"
    }
}

