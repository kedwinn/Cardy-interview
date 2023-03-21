# create a VPC
resource "aws_vpc" "cardy_vpc" {
    cidr_block = var.vpc_cidrblock
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = "cardy_vpc"
    }
  
}

#Create a public subnet
resource "aws_subnet" "Pubsub1" {
    vpc_id = aws_vpc.cardy_vpc.id
    availability_zone = var.AZ1
    cidr_block = var.Pubsub1_cidrblock
    map_public_ip_on_launch = true
    tags = {
      Name = "Pubsub1"
    }
}
#create a private subnet
resource "aws_subnet" "Privsub1" {
    vpc_id = aws_vpc.cardy_vpc.id
    availability_zone = var.AZ2
    cidr_block = var.Privsub1_cidrblock
    map_public_ip_on_launch = true
    tags = {
      Name = "Privsub2"
    }
}

#create an internet gateway
resource "aws_internet_gateway" "cardy_igw" {
  vpc_id = aws_vpc.cardy_vpc.id
}

#create a routetable
resource "aws_route_table" "pubRT1" {
  vpc_id = aws_vpc.cardy_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.cardy_igw.id
  }
}

resource "aws_route_table" "privRT2" {
  vpc_id = aws_vpc.cardy_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.cardy_natgw.id
  }
}

#create 2 route table associations
resource "aws_route_table_association" "cardyRTA1" {
  subnet_id = aws_subnet.Privsub1.id
   route_table_id = aws_route_table.cardyRT1.id
}

resource "aws_route_table_association" "cardyRTA2" {
  subnet_id = aws_subnet.Privsub1.id
   route_table_id = aws_route_table.cardyRT2.id
}

#create an EIP for NAT
resource "aws_eip" "cardyeip" {
  vpc = true
}

#Create a NATgateway
resource "aws_nat_gateway" "cardy_natgw" {
  allocation_id = aws_eip.cardyeip.id
subnet_id = aws_subnet.Pubsub1.id
}


#Create a publickey pair
resource "aws_key_pair" "cardykey" {
  key_name = "cardykey"
  public_key ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKJcvf7miuRlUqLbAiNFvCVGa50o1dw2xfeF6eLnVX7YfwdndJnhuuuoqmMRqVQDdEoxuCgQX2yBKyrhrG2C8/YlWX+eHVAPtPMg7wGKNMNmHTzWUCUyTkoIvMqeqNMmFcUSUuVfl6k/hJORTs8qJDeh8BIz6ocfF0kZyqq86k8XtcZntqXSWoDN689+J3khIeUczKGGfnMN0GYF+rMSetUEeiBIePwXspE8TIlskrXOOQUG8bceKrP6ThGJy3Nn91BlLTDMgRA8GSaYERCfJx0Ebdbh4L4H0pX+yLs1kw+f9SCu2zJ9D/fVca8SRG53fAn+DLJxreT4QoWFQSg48UjX1IJlPIJ+/uCMtKwx+VCj2F5HAr3X6yCqu1x6925uNz324VvQUm2Xy6V35vlopY8QFMmo8uY2YqYYky7FopnB3NjGAmWQg3U+Qd/NEjvVSz95X5TLcMdhOkzpNw6DIC6KQnQm24XjMn8iURgHThXPvdU/00iZ1734Zme7taA+s= admin@PF313WVE-JDV"
}


#Create an EC2 instance
resource "aws_instance" "nginxserver" {
  instance_type          = var.instance_type
  ami                    = var.instance_ami
  availability_zone      = var.AZ1
  vpc_security_group_ids = [aws_security_group.cardy_sg.id]
  key_name               = var.key_name
  user_data              = file("installnginx.sh")
  tags{
    Name = "nginxserver"
  }
} 


#create a security group
resource "aws_security_group" "cardy_sg" {
  name        = "cardy_sg"
  description = "allow ssh on 22 and http on port 80"
  vpc_id      = aws_default_vpc.cardy_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    tags{
    Name = "cardy_sg"
  }
}

#create an the ALB
resource  "aws_alb" "cardyalb" {
  name = "cardyAlb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.albsg.id]
  subnets = ["aws_subnet.Pubsub1.id" ]
  tags = {
    "Name" = "cardy"
  }
}

#create the ALB target 
resource "aws_alb_target_group" "cardyalbtargetgroup" {
  name = "cardyalbtargetgroup"
  port =  80
  protocol = "HTTP"
  vpc_id = aws_vpc.cardy_vpc.id
    stickiness {
    type = "lb_cookie"
    }
}

# create ALB Listerner HTTPS
resource "aws_alb_listener" "cardyalblisterner" {
  load_balancer_arn = aws_alb.cardyalb.arn
  port = 80
  protocol = "HTTP"
    default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.cardyalbtargetgroup.arn
    }
}