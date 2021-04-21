//Why cant terraform find the vpc?
data "aws_vpc" "vpc" {
  id = module.networking.aws_vpc_id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http_from_VPC"
  description = "Allow basic http traffic"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "http"
    cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = [data.aws_vpc.vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "secure http from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = [data.aws_vpc.vpc.ipv6_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}