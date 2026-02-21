########################################################################################
#Create VPC
########################################################################################
resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.dev_vpc
  enable_dns_hostnames = true

  tags = {
    Name = "dev_vpc"
  }
}

########################################################################################
#Create Internet Gateway
########################################################################################
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "DevOps_Internet_Gateway"
  }
}

########################################################################################
#Public route table
########################################################################################
resource "aws_route_table" "dev_public_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = var.public_route_table
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "Public_route_table"
  }
}

########################################################################################
#Subnets
########################################################################################
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.subnet_1
  map_public_ip_on_launch = true
  availability_zone       = var.az_1a

  tags = { Name = "public_subnet_1" }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.subnet_2
  map_public_ip_on_launch = true
  availability_zone       = var.az_1d

  tags = { Name = "public_subnet_2" }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.subnet_3
  map_public_ip_on_launch = false
  availability_zone       = var.az_1b

  tags = { Name = "private_subnet_3" }
}

resource "aws_subnet" "private_subnet_4" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.subnet_4
  map_public_ip_on_launch = false
  availability_zone       = var.az_1b

  tags = { Name = "private_subnet_4" }
}

########################################################################################
#Public Route Table Association
########################################################################################
resource "aws_route_table_association" "public_rt_association_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.dev_public_route_table.id
}

resource "aws_route_table_association" "public_rt_association_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.dev_public_route_table.id
}

########################################################################################
#NAT Gateway
########################################################################################
resource "aws_eip" "nat_gateway" {
  domain = "vpc"
  tags   = { Name = "nat_gateway_eip" }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags          = { Name = "nat_gateway" }
}

########################################################################################
#Private Route Table  
########################################################################################
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = { Name = "Private_route_table" }
}

########################################################################################
#Private Route Table Associations
########################################################################################
resource "aws_route_table_association" "private_route_table_association_subnet_03" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_subnet_04" {
  subnet_id      = aws_subnet.private_subnet_4.id
  route_table_id = aws_route_table.private_route_table.id
}

########################################################################################
#Security Groups 
########################################################################################
#APPLICATION LOAD BALANCER SECURITY GROUP
resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = aws_vpc.dev_vpc.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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


#PUBLIC EC2 SECURITY GROUP
resource "aws_security_group" "public_ssg_ec2" {
  name   = "public_sg"
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_host_ingress_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#BASTION EC2 SECURITY GROUP
resource "aws_security_group" "bastion_host" {
  name   = "bastion_sg"
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_host_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#PRIVATE EC2 SECURITY GROUP
resource "aws_security_group" "ssg_private_subnet_3" {
  name   = "private_sg"
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################################################################
# EC2S
########################################################################################

#Public EC2 IN SUBNET 1
resource "aws_instance" "dev_public_ec2" {
  ami                         = var.AMMID
  instance_type               = var.EC2_type
  associate_public_ip_address = true
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.public_ssg_ec2.id]

  tags = { Name = "Public EC2 One" }
}



#Public EC2 IN SUBNET 2
resource "aws_instance" "dev_public_ec2_2" {
  ami                         = var.AMMID
  instance_type               = var.EC2_type
  associate_public_ip_address = true
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.public_ssg_ec2.id]

  tags = { Name = "Public EC2 Two" }
}



#BASTION EC2 IN SUBNET 2.
resource "aws_instance" "Bastion_host_ec2" {
  ami                         = var.AMMID
  instance_type               = var.EC2_type
  associate_public_ip_address = true
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.public_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]

  tags = { Name = "Bastion Host EC2" }
}



#Private EC2 IN SUBNET 3
resource "aws_instance" "dev_private_ec2" {
  ami                         = var.AMMID
  instance_type               = var.EC2_type
  associate_public_ip_address = false
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.private_subnet_3.id
  vpc_security_group_ids      = [aws_security_group.ssg_private_subnet_3.id]

  tags = { Name = "Private EC2" }
}


########################################################################################
#ALB Instance Target Group
########################################################################################
resource "aws_lb_target_group" "alb_target_group" {
  name     = "application-load-balancer"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev_vpc.id
}

########################################################################################
#ALB Target Group Attachment
########################################################################################
resource "aws_lb_target_group_attachment" "attachment_ec2_one" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.dev_public_ec2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attachment_ec2_two" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.dev_public_ec2_2.id
  port             = 80
}

########################################################################################
#ALB Listener
########################################################################################
# resource "aws_lb_listener" "listener_forward" {
#   load_balancer_arn = aws_lb.dev_test_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.acm_certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.alb_target_group.arn
#   }
# } SINCE WE DO NOT HAVE CERTIFICATE AND DOMAIN NAME AND AWS FREE TIER ACCOUNT DOES NOT ALLOW US TO CREATE A DOMAIN. SO WE WILL USE LISTENER ON PORT 80.

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.dev_test_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}



########################################################################################
#Application Load Balancer
########################################################################################
resource "aws_lb" "dev_test_alb" {
  name                       = "dev-test-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false


  tags = {
    Environment = "production Environment"
  }
}




