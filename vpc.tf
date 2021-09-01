###########################################################################
#List of AWS Availability Zones in thie account
##########################################################################

data "aws_availability_zones" "az" {
  state = "available"
}


###########################################################################
# Vpc Creation
###########################################################################

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
lifecycle {
    create_before_destroy = true
  }
}

###########################################################################
# Igw Creation
###########################################################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-igw"
  }
lifecycle {
    create_before_destroy = true
  }
}

###########################################################################
# Subnet Creation public 1
###########################################################################

resource "aws_subnet" "public1" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 0)
  availability_zone = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public1"
  }

}

###########################################################################
# Subnet Creation public 2
###########################################################################

resource "aws_subnet" "public2" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 1)
  availability_zone = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public2"
  }

}

###########################################################################
# Subnet Creation public 3
###########################################################################

resource "aws_subnet" "public3" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 2)
  availability_zone = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public3"
  }

}

###########################################################################
# Subnet Creation private1
###########################################################################

resource "aws_subnet" "private1" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 3)
  availability_zone = data.aws_availability_zones.az.names[4]
  tags = {
    Name = "${var.project}-private1"
  }

}

###########################################################################
# Subnet Creation private2
###########################################################################

resource "aws_subnet" "private2" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 4)
  availability_zone = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-private2"
  }

}

###########################################################################
# Subnet Creation private3
###########################################################################

resource "aws_subnet" "private3" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 5)
  availability_zone = data.aws_availability_zones.az.names[5]
  tags = {
    Name = "${var.project}-private3"
  }

}

###########################################################################
#Elastic Ip Creation
###########################################################################

resource "aws_eip" "eip" {

  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
  }
}

##########################################################################
#Allocate Elastic IP to NAT
##########################################################################

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project}-NAT"
  }
}

#########################################################################
#Public Route table
#########################################################################

resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.main.id

  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }

  tags = {
    Name = "route1"
  }

}

###########################################################################
# Private Route table
###########################################################################

resource "aws_route_table" "route2" {
  vpc_id = aws_vpc.main.id

  route{
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat.id
    }

  tags = {
    Name = "route2"
  }

}

################################################################################
# Public Route table associations
################################################################################

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.route1.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.route1.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.route1.id
}


################################################################################
# Public Route table associations
################################################################################

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.route2.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.route2.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.route2.id
}
