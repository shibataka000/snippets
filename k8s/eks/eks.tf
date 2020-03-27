provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  backend "s3" {
    bucket = "sbtk-tfstate"
    key    = "snippets/k8s/eks.tf"
    region = "ap-northeast-1"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "demo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name                                        = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "public" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.demo.id

  tags = {
    Name                                        = "${var.cluster-name}-public"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = var.cluster-name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.1${count.index}.0/24"
  vpc_id            = aws_vpc.demo.id

  tags = {
    Name                                        = "${var.cluster-name}-private"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_eip" "private" {
  count = length(aws_subnet.private)
  vpc   = true
}

resource "aws_nat_gateway" "private" {
  count = length(aws_subnet.private)

  allocation_id = aws_eip.private[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = var.cluster-name
  }
}

resource "aws_route_table" "private" {
  count = length(aws_subnet.private)

  vpc_id = aws_vpc.demo.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private[count.index].id
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_iam_role" "demo-cluster" {
  name = "${var.cluster-name}-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo-cluster.name
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.demo-cluster.name
}

resource "aws_security_group" "demo-cluster" {
  name        = "${var.cluster-name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.cluster-name
  }
}

resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  role_arn = aws_iam_role.demo-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.demo-cluster.id]
    subnet_ids         = [for subnet in concat(aws_subnet.public, aws_subnet.private) : subnet.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy,
  ]

  provisioner "local-exec" {
    command = "aws --profile ${var.profile} --region ${var.region} eks update-kubeconfig --name ${var.cluster-name}"
  }
}

resource "aws_iam_role" "demo-node" {
  name = "${var.cluster-name}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.demo-node.name
}

resource "aws_eks_node_group" "demo" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "${aws_eks_cluster.demo.name}-node-group"
  node_role_arn   = aws_iam_role.demo-node.arn
  subnet_ids      = [for subnet in aws_subnet.private : subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }
}

resource "local_file" "config_map_aws_auth" {
  content  = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.demo-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
  filename = "config_map_aws_awth.yaml"

  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.config_map_aws_auth.filename}"
  }

  depends_on = [aws_eks_cluster.demo]
}
