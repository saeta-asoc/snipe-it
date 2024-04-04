resource "aws_key_pair" "snipeit" {
  key_name   = "snipeit"
  public_key = file("./web_key.pub")
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "snipeit_role" {
  name               = "snipeit-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "snipeit_s3_policy_attachment" {
  role       = aws_iam_role.snipeit_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create an instance profile for the launch template. It cannot use the role directly.
resource "aws_iam_instance_profile" "snipeit" {
  name = "snipeit-instance-profile"
  role = aws_iam_role.snipeit_role.name
}

resource "aws_launch_template" "snipeit" {
  name_prefix   = "snipeit-"
  image_id      = data.aws_ami.latest.id
  instance_type = var.instance_type
  user_data     = filebase64("${path.module}/user-data.sh")
  key_name      = aws_key_pair.snipeit.key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_block_device.volume_size
      volume_type           = var.root_block_device.volume_type
      delete_on_termination = var.root_block_device.delete_on_termination
    }
  }

  vpc_security_group_ids = [aws_security_group.snipeit.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.snipeit.arn
  }

}

resource "aws_autoscaling_group" "snipeit" {
  name_prefix      = aws_launch_template.snipeit.name_prefix
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  availability_zones = data.aws_availability_zones.available.names

  launch_template {
    id      = aws_launch_template.snipeit.id
    version = "$Latest"
  }
}

resource "aws_security_group" "snipeit" {
  name = "snipeit-lb-sb"
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  vpc_id = data.aws_vpc.default.id
}
