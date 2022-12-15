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

apt install -y software-properties-common apt-transport-https unzip
apt-key adv --keyserver keyserver.ubuntu.com --recv 8F3DA4B5E9AEF44C
add-apt-repository 'deb [ arch=all ] https://repo.vaticle.com/repository/apt/ trusty main' -y
apt update

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
aws --version

apt-get -y install typedb-all=2.14.1 typedb-server=2.14.1 typedb-console=2.12.0 typedb-bin=2.12.0
typedb server &

sleep 11

DATABASE_WORKDIR=graph_database
TDB_DATABASE_NAME=orp-mvp-v0.1
TDB_DATABASE_SCHEMA=orp-gdb-schema.tql
TDB_DATABASE_FILE=orp-mvp-kgdb.typedb

mkdir $DATABASE_WORKDIR
aws s3 sync s3://beis-orp-dev-graph-database $DATABASE_WORKDIR
typedb console --command='database create '$TDB_DATABASE_NAME'' --command='transaction '$TDB_DATABASE_NAME' schema write' --command='source '$DATABASE_WORKDIR'/'$TDB_DATABASE_SCHEMA'' --command='commit'
typedb server import --database=$TDB_DATABASE_NAME --file=$DATABASE_WORKDIR/$TDB_DATABASE_FILE --port=1729

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
