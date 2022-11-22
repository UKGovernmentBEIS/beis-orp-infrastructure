resource "aws_instance" "typedb" {
  ami = "ami-0f540e9f488cfa27d"
  instance_type = "t2.micro"

  availability_zone = "${local.region}a"
  subnet_id         = module.vpc.private_subnets[0]
  security_groups = [ module.vpc.default_security_group_id ]
  iam_instance_profile = aws_iam_instance_profile.ec2_resource_ssm_profile.name

  tags = {
    Name                   = "beis-orp-typedb"
  }

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
apt install software-properties-common apt-transport-https
apt-key adv --keyserver keyserver.ubuntu.com --recv 8F3DA4B5E9AEF44C
add-apt-repository 'deb [ arch=all ] https://repo.vaticle.com/repository/apt/ trusty main'
apt update

apt install typedb-all --assume-yes

log "user_data done"

typedb server &

EOF
}
