# Create IAM Role and Instance Profile
resource "aws_iam_role" "ec2_role" {
    name = "ec2_basic_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_basic_profile"
  role = aws_iam_role.ec2_role.name
}

# Create Public Subnet
# Create Public EC2
# checkov:skip=CKV_AWS_88: Need default public IP for lab/demo
resource "aws_instance" "public_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.public_sg_id]
  key_name                    = var.key_name
  ebs_optimized               = true
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "PublicInstance-${var.public_instance_name}"
  }
}


# Create Private EC2\
# checkov:skip=CKV2_AWS_41: EC2 private does not need IAM role for lab/demo purposes
resource "aws_instance" "private_instance" {
    ami                         = var.ami_id
    instance_type               = var.instance_type
    subnet_id                   = var.private_subnet_id
    vpc_security_group_ids      = [var.private_sg_id]
    key_name                    = var.key_name
    ebs_optimized               = true
    monitoring                  = true
    iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

    metadata_options {
        http_tokens   = "required"
        http_endpoint = "enabled"
    }

    root_block_device {
        encrypted = true
    }

    tags = {
        Name = "PrivateInstance-${var.private_instance_name}"
    }
}