provider "aws" {
  region = var.region
}

resource "aws_internet_gateway_attachment" "lab2_igw_attach" {
  vpc_id              = aws_vpc.lab2_vpc.id
  internet_gateway_id = aws_internet_gateway.lab2_igw.id
}

resource "aws_vpc" "lab2_vpc" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_internet_gateway" "lab2_igw" {}

resource "aws_subnet" "lab2_subnet1a" {
  vpc_id            = aws_vpc.lab2_vpc.id
  availability_zone = "ap-south-1a"
  cidr_block        = "172.16.1.0/24"
}

resource "aws_subnet" "lab2_subnet1b" {
  vpc_id            = aws_vpc.lab2_vpc.id
  availability_zone = "ap-south-1b"
  cidr_block        = "172.16.2.0/24"
}

resource "aws_security_group" "lab2-sg-ec2" {
  description = "To allow HTTP and SSH access"
  vpc_id      = aws_vpc.lab2_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "lab2-sg-lb" {
  description = "To allow HTTP and SSH access"
  vpc_id      = aws_vpc.lab2_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "lab2_rt1" {
  vpc_id = aws_vpc.lab2_vpc.id

}

resource "aws_route" "lab2_public_access" {
  route_table_id         = aws_route_table.lab2_rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab2_igw.id

}

resource "aws_route_table_association" "lab2_1a" {
  route_table_id = aws_route_table.lab2_rt1.id
  subnet_id      = aws_subnet.lab2_subnet1a.id
}

resource "aws_route_table_association" "lab2_1b" {
  route_table_id = aws_route_table.lab2_rt1.id
  subnet_id      = aws_subnet.lab2_subnet1b.id
}

resource "aws_instance" "lab2_webserver1" {
  ami                    = var.aws_ami
  instance_type          = var.instance_type
  key_name               = var.aws_key_pair
  vpc_security_group_ids = aws_security_group.lab2-sg-ec2.id
  subnet_id              = aws_subnet.lab2_subnet1a.id
  #user_data_base64       = base64decode(file("userdata1.sh"))
  #user_data              = base64decode(file("userdata.sh"))

}

resource "aws_instance" "lab2_webserver2" {
  ami                    = var.aws_ami
  instance_type          = var.instance_type
  key_name               = var.aws_key_pair
  vpc_security_group_ids = aws_security_group.lab2-sg-ec2.id
  subnet_id              = aws_subnet.lab2_subnet1a.id
  #user_data_base64       = base64decode(file("userdata1.sh"))
  # user_data              = base64decode(file("userdata1.sh"))

}

resource "aws_lb_target_group" "lab2_tg" {
  name     = "lab2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab2_vpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 300
  }

}

resource "aws_lb" "lab2_lb" {
  name               = "lab2-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_security_group.lab2-sg-lb.id
  subnets            = [aws_subnet.lab2_subnet1a, aws_subnet.lab2_subnet1b]

}

resource "aws_lb_listener" "lab2_lb_to_tg_listner" {
  load_balancer_arn = aws_lb.lab2_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab2_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "lab2_ec2_1" {
  target_group_arn = aws_lb_target_group.lab2_tg.arn
  target_id        = aws_instance.lab2_webserver1
  port             = 80

}

resource "aws_lb_target_group_attachment" "lab2_ec2_2" {
  target_group_arn = aws_lb_target_group.lab2_tg.arn
  target_id        = aws_instance.lab2_webserver2
  port             = 80
