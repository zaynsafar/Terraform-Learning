resource "aws_instance" "my_aws" {
  ami           = "ami-006d3995d3a6b963b"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.TF_SG.name]
  key_name  = "TF_key"
  tags = {
    Name = "Terraform_AWS"
  }
}

resource "aws_eip" "lb" {
  instance = "i-0ba33d92baa8090af"
  vpc      = true
}

resource "aws_ami_from_instance" "example" {
  name               = "terraform-example"
  source_instance_id = "i-0ba33d92baa8090af"
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = aws_instance.my_aws.id
}

resource "aws_ebs_volume" "this" {
  availability_zone = aws_instance.my_aws.availability_zone
  size              = 1

  tags = {
    Name = "Terraform_Volume"
   }
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}

#security group using terraform

resource "aws_security_group" "TF_SG" {
  name        = "security group using terraform"
  description = "security group using terraform"
  vpc_id      = "vpc-07c589f27f5da4cf0"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
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

  tags = {
    Name = "TF_SG"
  }
}
