provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key = "snippets/k8s/kubernetes-the-hard-way/kubernetes-the-hard-way.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_availability_zones" "available" {}

data "http" "ifconfig" {
  url = "https://ifconfig.co"
}

resource "aws_vpc" "demo" {
  cidr_block = "10.240.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "kubernetes-the-hard-way"
  } 
}

resource "aws_subnet" "demo" {
  count = 2
  vpc_id = aws_vpc.demo.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = "10.240.${count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "kubernetes-the-hard-way"
  } 
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id
  tags = {
    Name = "kubernetes-the-hard-way"
  }
}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }

  dynamic "route" {
    for_each = [0, 1, 2]
    content {
      cidr_block = "10.200.${route.value}.0/24"
      instance_id = aws_instance.k8s_workers[route.value].id
    }
  }
}

resource "aws_route_table_association" "demo" {
  count = length(aws_subnet.demo)
  subnet_id = aws_subnet.demo[count.index].id
  route_table_id = aws_route_table.demo.id
}

resource "aws_instance" "k8s_controllers" {
  count = 3
  ami = data.aws_ami.ubuntu.image_id
  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  instance_type = "t3.micro"
  key_name = "default"
  subnet_id = aws_subnet.demo[0].id
  private_ip = "10.240.0.1${count.index}"
  tags = {
    Name = "controller-${count.index}"
  }
}

resource "aws_instance" "k8s_workers" {
  count = 3
  ami = data.aws_ami.ubuntu.image_id
  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  instance_type = "t3.micro"
  key_name = "default"
  subnet_id = aws_subnet.demo[0].id
  private_ip = "10.240.0.2${count.index}"
  tags = {
    Name = "worker-${count.index}"
  }
}

resource "aws_security_group" "k8s_cluster" {
  name = "k8s-cluster"
  description = "kubernetes-the-hard-way"
  vpc_id = aws_vpc.demo.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.ifconfig.body)}/32"]
  }

  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "api_server" {
  name = "kubernetes-the-hard-way"
  load_balancer_type = "network"
  subnets = aws_subnet.demo[*].id
}

resource "aws_lb_listener" "api_server" {
  load_balancer_arn = aws_lb.api_server.arn
  port = "6443"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.api_server.arn
  }
}

resource "aws_lb_target_group" "api_server" {
  name = "api-server"
  port = 6443
  protocol = "TCP"
  target_type = "ip"
  vpc_id = aws_vpc.demo.id
}

resource "aws_lb_target_group_attachment" "api_server" {
  count = length(aws_instance.k8s_controllers)
  target_group_arn = aws_lb_target_group.api_server.arn
  target_id = aws_instance.k8s_controllers[count.index].private_ip
  port = 6443
}
