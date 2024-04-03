provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      project = var.project_name
      environment = var.environment
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "snipeit" {
  key_name   = "snipeit"
  public_key = file("./web_key.pub")
}

resource "aws_launch_template" "snipeit" {
  name_prefix     = "snipeit-"
  image_id        = data.aws_ami.latest.id
  instance_type   = var.instance_type
  user_data       = filebase64("user-data.sh")
  key_name        = aws_key_pair.snipeit.key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.root_block_device.volume_size
      volume_type = var.root_block_device.volume_type
      delete_on_termination = var.root_block_device.delete_on_termination
    }
  }

  vpc_security_group_ids = [aws_security_group.snipeit.id]

}

resource "aws_autoscaling_group" "snipeit" {
  name_prefix          = aws_launch_template.snipeit.name_prefix
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity

  availability_zones = data.aws_availability_zones.available.names

  launch_template {
    id      = aws_launch_template.snipeit.id
    version = "$Latest"
  }
}

resource "aws_security_group" "snipeit" {
  name = "snipeit-lb-sb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  vpc_id = data.aws_vpc.default.id
}

## S3 Bucket for backups
resource "aws_s3_bucket" "backup" {
  bucket_prefix = "snipeit-backups"
}

resource "aws_s3_bucket_public_access_block" "backup_access" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backup_versioning" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}
