# Configure the AWS Provider
provider "aws" {
  region = var.region
}
# Setup VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "project"
  }
}

resource "aws_eip" "eip" {
  vpc = true
}


# Add NAT GW
resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.web.id
  allocation_id = aws_eip.eip.id
  tags = {
    Name = "project"
  }
}

# Add Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW_main"
  }
}
# Create Subnets
resource "aws_subnet" "alb" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.sn_alb_cidr_block
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ALB"
  }
}
resource "aws_subnet" "alb2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.sn_alb2_cidr_block
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ALB"
  }
}
resource "aws_subnet" "web" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.sn_web_cidr_block

  tags = {
    Name = "WEB"
  }
}
resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.sn_db_cidr_block
  availability_zone = "us-east-2a"

  tags = {
    Name = "DATABASE"
  }
}
resource "aws_subnet" "database2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.sn_db2_cidr_block
  availability_zone = "us-east-2b"

  tags = {
    Name = "DATABASE"
  }
}
resource "aws_security_group" "sg_db" {
  name        = "allow_postgre"
  description = "Access to the database is limited by security groups. Web servers are deployed in the separate subnet of the database, and can only execute queries on the database. There is no other access to the database."
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.sn_web_cidr_block]
  }
  tags = {
    Name = "DATABASE"
  }
}
resource "aws_security_group" "sg_web" {
  name        = "allow_http"
  description = "Access to the WEB servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "WEB"
  }
}

# Create DB subnet group
resource "aws_db_subnet_group" "db_sg" {
  name       = "postgre"
  subnet_ids = [aws_subnet.database.id, aws_subnet.database2.id]

  tags = {
    Name = "My PostgreSQL DB subnet group"
  }
}
# Create PosrgreSQL DB
resource "aws_db_instance" "postgresql" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = var.db_version
  instance_class         = var.db_instance_class
  name                   = "PG1"
  username               = "dbadmin"
  password               = "changeme"
  vpc_security_group_ids = [aws_security_group.sg_db.id]
  db_subnet_group_name   = aws_db_subnet_group.db_sg.name

  tags = {
    Name = "PG1"
  }
}
# Create autoscaling group
resource "aws_launch_template" "web" {
  name_prefix            = "web"
  image_id               = var.ami_id
  instance_type          = var.web_instance_type
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  user_data              = base64encode(file("install_app.sh"))

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "WEB"
  }
}
resource "aws_autoscaling_group" "asg_web" {
  availability_zones  = ["us-east-2a"]
  vpc_zone_identifier = [aws_subnet.web.id]
  desired_capacity    = var.asg_desire_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  target_group_arns   = [aws_lb_target_group.alb_tg.arn]
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}
# Add Application Load Balancer and configure it
resource "aws_lb" "alb_main" {
  name               = "alb-prod"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_web.id]
  subnets            = [aws_subnet.alb.id, aws_subnet.alb2.id]

  tags = {
    Name = "ALB"
  }
}
resource "aws_lb_target_group" "alb_tg" {
  name     = "target-group-for-lb"
  port     = var.http_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.alb_main.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

