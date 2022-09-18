
data "aws_vpc" "dev_vpc" {
  tags = {
    Name = "dev"
  }
}

#==================Create Subnet=======================#

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = data.aws_vpc.dev_vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = data.aws_vpc.dev_vpc.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}

#=====================IGW,Routing=======================#

resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.dev_vpc.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_route_table" "public_subnets" {
  count  = length(var.public_subnets)
  vpc_id = data.aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = data.aws_vpc.dev_vpc.id
  tags = {
    Name = "${var.env}-route-private-subnets"
  }
}

resource "aws_route" "private" {
  count                  = length(compact(var.private_subnets))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}


resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = element(aws_route_table.public_subnets[*].id, count.index)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

#===================EIP-NAT===============================#

resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  vpc   = true
  tags = {
    Name = "${var.env}-gw-nat-${count.index + 1}"
  }
}


resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]
  tags = {
    Name = "${var.env}-igw-private"
  }
}
