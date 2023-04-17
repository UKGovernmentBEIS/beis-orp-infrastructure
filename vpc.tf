module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

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

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.19.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]


  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids = [
        module.vpc.public_subnets[0],
        module.vpc.public_subnets[1],
        module.vpc.public_subnets[2]
      ]
    }
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids = [
        module.vpc.public_subnets[0],
        module.vpc.public_subnets[1],
        module.vpc.public_subnets[2]
      ]
    }
    ec2_messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids = [
        module.vpc.public_subnets[0],
        module.vpc.public_subnets[1],
        module.vpc.public_subnets[2]
      ]
    }
    s3 = {
      # interface endpoint
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    }
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.sqs_vpc_endpoint.id]
      subnet_ids = [
        module.vpc.public_subnets[0],
        module.vpc.public_subnets[1],
        module.vpc.public_subnets[2]
      ]
      tags = { Name = "sqs-vpc-endpoint" }
    }
  }

  #    endpoints = {

  #    dynamodb = {
  #      # gateway endpoint
  #      service         = "dynamodb"
  #      route_table_ids = ["rt-12322456", "rt-43433343", "rt-11223344"]
  #      tags            = { Name = "dynamodb-vpc-endpoint" }
  #    },
  #    sns = {
  #      service    = "sns"
  #      subnet_ids = ["subnet-12345678", "subnet-87654321"]
  #      tags       = { Name = "sns-vpc-endpoint" }
  #    },


  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

resource "aws_elasticache_subnet_group" "ecs" {
  name       = "ecs-subnet"
  subnet_ids = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1],
    module.vpc.public_subnets[2]
  ]
}
