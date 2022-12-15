resource "aws_instance" "typedb" {
  #  ami           = "ami-04706e771f950937f" // AWS Linux
  ami           = "ami-0f540e9f488cfa27d" // Ubuntu
  instance_type = "t2.micro"

  availability_zone      = "${local.region}a"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.typedb_instance.id, module.vpc.default_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.typedb_iam_profile.name

  tags = {
    Name = "beis-orp-typedb"
  }

  user_data_replace_on_change = true

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 20
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<EOF
#!/bin/bash

apt install -y software-properties-common apt-transport-https
apt-key adv --keyserver keyserver.ubuntu.com --recv 8F3DA4B5E9AEF44C
add-apt-repository 'deb [ arch=all ] https://repo.vaticle.com/repository/apt/ trusty main' -y
apt update

apt-get -y install typedb-all=2.14.1 typedb-server=2.14.1 typedb-console=2.12.0 typedb-bin=2.12.0
typedb server &

EOF
}

resource "aws_instance" "mongo_bastion" {
  #  ami           = "ami-04706e771f950937f" // AWS Linux
  ami           = "ami-0f540e9f488cfa27d" // Ubuntu
  instance_type = "t2.micro"

  availability_zone      = "${local.region}a"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.mongo_bastion_instance.id, module.vpc.default_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_resource_ssm_profile.name

  tags = {
    Name = "beis-orp-mongo-bastion"
  }

  user_data_replace_on_change = true

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 20
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<EOF
#!/bin/bash

apt install -y software-properties-common apt-transport-https
apt-key adv --keyserver keyserver.ubuntu.com --recv 8F3DA4B5E9AEF44C
add-apt-repository 'deb [ arch=all ] https://repo.vaticle.com/repository/apt/ trusty main' -y
apt update

EOF
}
