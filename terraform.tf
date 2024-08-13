provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "yoge_k8s_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "yogesh_k8s_vpc"
  }
}

resource "aws_internet_gateway" "yogesh_IGW" {
  vpc_id = aws_vpc.yoge_k8s_vpc.id
  tags = {
    Name = "yogesh_IGW"
  }
}

resource "aws_subnet" "yogesh_public_subnet" {
  vpc_id                  = aws_vpc.yoge_k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "yogesh_public_subnet"
  }
}

resource "aws_route_table" "yogesh_public_routetable" {
  vpc_id = aws_vpc.yoge_k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yogesh_IGW.id
  }
  tags = {
    Name = "yogesh_public_routetable"
  }
}

resource "aws_route_table_association" "yogesh_public_routeassoci" {
  subnet_id      = aws_subnet.yogesh_public_subnet.id
  route_table_id = aws_route_table.yogesh_public_routetable.id
}

resource "aws_security_group" "yoge_k8s_sg" {
  vpc_id = aws_vpc.yoge_k8s_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows traffic from any IP address
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows traffic to any IP address
  }

  tags = {
    Name = "yoge_k8s_sg"
  }
}

resource "aws_instance" "yoge_k8s_bastion" {
  ami           = "ami-04a81a99f5ec58529"  # Ubuntu 
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.yogesh_public_subnet.id
  security_groups = [aws_security_group.yoge_k8s_sg.id]
  key_name      = "yogesh-key-pair"  

  root_block_device {
    volume_size = 30  
  }

  tags = {
    Name = "Yogesh-K8s-bastion"
  }
}


output "vpc_id" {
  value = aws_vpc.yoge_k8s_vpc.id
}

output "subnet_id" {
  value = aws_subnet.yogesh_public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.yoge_k8s_sg.id
}

output "bastion_instance_id" {
  value = aws_instance.yoge_k8s_bastion.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.yogesh_IGW.id
}

output "route_table_id" {
  value = aws_route_table.yogesh_public_routetable.id
}
