/* Here I will create Security group allowing HTTP and SSH access,
and two EC2s machines.
*/

provider "aws" {
  region = "us-east-1"
}

locals {
  vpc_id           = "vpc-0d282f55b6dc0e5be"    # pre-provisioned VPC 
  subnet_id        = "subnet-0cc1ac558193babad" # pre-provisioned subnet of VPC, it should be in us-east-1 region
  ssh_user         = "ec2-user"                 # user of ami-05ffe3c48a9991133
  key_name         = "devops"                   # pre-created SSH key-pair
  private_key_path = "/users/hosha/devops.pem"  # absolute path to SSH key
}

# Creating SG:

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating two EC2:

resource "aws_instance" "nginx" {
  count                       = 2
  ami                         = "ami-05ffe3c48a9991133"
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  # Use vpc_security_group_ids for VPC compatibility instead of security_groups
  vpc_security_group_ids = [aws_security_group.nginx.id]
  key_name               = local.key_name

  tags = {
    Name        = "nginx-${count.index}"
    Role        = "web"
    Environment = "dev"
  }

  provisioner "remote-exec" {
    inline = ["echo 'SSH is ready on instance ${count.index}'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = self.public_ip
    }
  }
}

# Output IPs:

output "nginx_ips" {
  value = [for instance in aws_instance.nginx : instance.public_ip]
}