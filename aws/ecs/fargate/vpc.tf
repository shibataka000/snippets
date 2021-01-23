data "aws_availability_zones" "available" {}

resource "aws_vpc" "demo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = var.cluster-name
  }
}

resource "aws_subnet" "public" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index + 1]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.demo.id

  tags = {
    Name = "${var.cluster-name}-public"
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

  availability_zone = data.aws_availability_zones.available.names[count.index + 1]
  cidr_block        = "10.0.1${count.index}.0/24"
  vpc_id            = aws_vpc.demo.id

  tags = {
    Name = "${var.cluster-name}-private"
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

# PrivateLink

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.cluster-name}-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.cluster-name}-ecr-api"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.cluster-name}-logs"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.demo.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
  tags = {
    Name = "${var.cluster-name}-s3"
  }
}

resource "aws_security_group" "vpc_endpoint" {
  vpc_id = aws_vpc.demo.id
  name   = "${var.cluster-name}-vpc-endpoint"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.sample.id]
  }

  tags = {
    Name = "${var.cluster-name}-vpc-endpoint"
  }
}
