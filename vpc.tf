# Create a test VPC
resource "aws_vpc" "beis_orp" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subneta" {
  vpc_id = aws_vpc.beis_orp.id
  cidr_block = "10.0.0.0/18"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "subnetb" {
  vpc_id = aws_vpc.beis_orp.id
  cidr_block = "10.0.64.0/18"
  availability_zone = "eu-west-2b"
}

resource "aws_subnet" "subnetc" {
  vpc_id = aws_vpc.beis_orp.id
  cidr_block = "10.0.128.0/18"
  availability_zone = "eu-west-2c"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.beis_orp.id
  tags = {
    Name = "beis-orp"
  }
}