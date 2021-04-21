data "aws_ami" "nginx" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-nginx-1.14.0-1-linux-debian-9-x86_64-hvm-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"]
}

// Add subnet
# data  "name" {
  
# }

resource "aws_elb" "elb" {
  name               = "${var.environment}-elb-terraform-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  access_logs {
    bucket        = "${var.environment}-bucket"
    bucket_prefix = "elb"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.nginx.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name        = "${var.environment}-nlb"
    Environment = "${var.environment}"
  }
}

resource "aws_instance" "nginx" {
  ami           = data.aws_ami.nginx.id
  instance_type = "t3.micro"

  tags = {
    Name        = "${var.environment}-ec2"
    Environment = "${var.environment}"
  }
}

resource "aws_elb_attachment" "nlb_attachement" {
  elb      = aws_elb.elb.id
  instance = aws_instance.nginx.id
}