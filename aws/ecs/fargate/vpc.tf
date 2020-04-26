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

