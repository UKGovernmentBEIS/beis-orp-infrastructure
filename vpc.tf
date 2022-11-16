## Create a test VPC
#resource "aws_vpc" "beis_orp" {
#  cidr_block = "10.0.0.0/16"
#}
#
#resource "aws_subnet" "subneta" {
#  vpc_id = aws_vpc.beis_orp.id
#  cidr_block = "10.0.0.0/18"
#  availability_zone = "eu-west-2a"
#}
#
#resource "aws_subnet" "subnetb" {
#  vpc_id = aws_vpc.beis_orp.id
#  cidr_block = "10.0.64.0/18"
#  availability_zone = "eu-west-2b"
#}
#
#resource "aws_subnet" "subnetc" {
#  vpc_id = aws_vpc.beis_orp.id
#  cidr_block = "10.0.128.0/18"
#  availability_zone = "eu-west-2c"
#}
#
#resource "aws_internet_gateway" "gw" {
#  vpc_id = aws_vpc.beis_orp.id
#  tags = {
#    Name = "beis-orp"
#  }
#}
#
#resource "aws_route_table" "rtb_beis" {
#  vpc_id = aws_vpc.beis_orp.id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.gw.id
#  }
#  tags = {
#    Name = "rtb-beis"
#  }
#}
#
#resource "aws_route_table_association" "beis_a" {
#  subnet_id      = aws_subnet.subneta.id
#  route_table_id = aws_route_table.rtb_beis.id
#}
#
#resource "aws_route_table_association" "beis_b" {
#  subnet_id      = aws_subnet.subnetb.id
#  route_table_id = aws_route_table.rtb_beis.id
#}
#
#resource "aws_route_table_association" "beis_c" {
#  subnet_id      = aws_subnet.subnetc.id
#  route_table_id = aws_route_table.rtb_beis.id
#}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
  #for_each = local.vpc
  name = "beis_orp"
  cidr = "10.0.0.0/16"
  azs = [
    "${local.region}a",
    "${local.region}b",
    "${local.region}c",
  ]
  public_subnets = [
    "10.0.0.0/19",
    "10.0.32.0/19",
    "10.0.64.0/19"
  ]
  private_subnets = [
    "10.0.128.0/19",
    "10.0.160.0/19",
    "10.0.192.0/19"
  ]

  enable_ipv6          = false
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}
