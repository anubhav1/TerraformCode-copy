terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  //alias  = "primary"
  //profile = "default"  
  region  = "eu-central-1"
}

provider "aws" {
  alias  = "secondary"
  region = "us-east-1"
}

terraform {
    backend "s3" {
      encrypt = true
      bucket = "my-tf-test-bucket7827"
      dynamodb_table = "Terraform-State-Lock-Dynamo"
      key = "path/path/terraform.tfstate"
      region = "eu-central-1"
  }
}

# Creating VPC
resource "aws_vpc" "ghostvpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"
  tags = {
    Name = "GhostVPC"
  }
}

#Creating VPC2
resource "aws_vpc" "ghostvpc2" {
  provider = aws.secondary  
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"
  tags = {
    Name = "GhostVPC2"
  }
}


# Creating 1st Public subnet 
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = "${aws_vpc.ghostvpc.id}"
  cidr_block             = "${var.public_subnet1_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "${var.az1}"
tags = {
    Name = "Public Subnet 1"
  }
}

# Creating 2nd Public subnet 
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = "${aws_vpc.ghostvpc.id}"
  cidr_block             = "${var.public_subnet2_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "${var.az2}"
tags = {
    Name = "Public Subnet 2"
  }
}

# Creating 1st application subnet 
resource "aws_subnet" "application-subnet-1" {
  vpc_id                  = "${aws_vpc.ghostvpc.id}"
  cidr_block             = "${var.application_subnet1_cidr}"
  map_public_ip_on_launch = false
  availability_zone = "${var.az1}"
tags = {
    Name = "Application Subnet 1"
  }
}
# Creating 2nd application subnet 
resource "aws_subnet" "application-subnet-2" {
  vpc_id                  = "${aws_vpc.ghostvpc.id}"
  cidr_block             = "${var.application_subnet2_cidr}"
  map_public_ip_on_launch = false
  availability_zone = "${var.az2}"
tags = {
    Name = "Application Subnet 2"
  }
}
# Create Database Private Subnet
resource "aws_subnet" "database-subnet-1" {
  vpc_id            = "${aws_vpc.ghostvpc.id}"
  cidr_block        = "${var.database_subnet1_cidr}"
  availability_zone = "${var.az1}"
tags = {
    Name = "Database Subnet 1"
  }
}
# Create Database Private Subnet
resource "aws_subnet" "database-subnet-2" {
  vpc_id            = "${aws_vpc.ghostvpc.id}"
  cidr_block        = "${var.database_subnet2_cidr}"
  availability_zone = "${var.az2}"
tags = {
    Name = "Database Subnet 2"
  }
}
# Create Database Private Subnet
resource "aws_subnet" "database-subnet-1a" {
  provider = aws.secondary  
  vpc_id            = "${aws_vpc.ghostvpc2.id}"
  cidr_block        = "${var.database_subnet1_cidr}"
  availability_zone = "us-east-1a"
tags = {
    Name = "Database Subnet 1a"
  }
}
# Create Database Private Subnet
resource "aws_subnet" "database-subnet-2a" {
  provider = aws.secondary  
  vpc_id            = "${aws_vpc.ghostvpc2.id}"
  cidr_block        = "${var.database_subnet2_cidr}"
  availability_zone = "us-east-1b"
tags = {
    Name = "Database Subnet 2a"
  }
}


resource "aws_internet_gateway" "internetgateway" {
  vpc_id = "${aws_vpc.ghostvpc.id}"
}

# Creating Routes
resource "aws_route_table" "route" {
    vpc_id = "${aws_vpc.ghostvpc.id}"
route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internetgateway.id}"
    }
tags = {
        Name = "Route to public internet"
    }
}

# Associating Route Table1
resource "aws_route_table_association" "rt1" {
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    route_table_id = "${aws_route_table.route.id}"
}

# Associating Route Table2
resource "aws_route_table_association" "rt2" {
    subnet_id = "${aws_subnet.public-subnet-2.id}"
    route_table_id = "${aws_route_table.route.id}"
}



# Creating Security Group 
resource "aws_security_group" "ec2-sg" {
vpc_id = "${aws_vpc.ghostvpc.id}"
# Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "EC2 SG"
  }
}


# Create Database Security Group
resource "aws_security_group" "database-sg" {
  name        = "Database SG"
  description = "Allow inbound traffic from application layer"
  vpc_id      = aws_vpc.ghostvpc.id
ingress {
    description     = "Allow traffic from application layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2-sg.id]
  }
egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "Database SG"
  }
}  

resource "aws_security_group" "database-sg2" {
  provider = aws.secondary
  name        = "Database SG"
  description = "Allow inbound traffic from application layer"
  vpc_id      = aws_vpc.ghostvpc2.id
ingress {
    description     = "Allow traffic from application layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "Ghost Database SG"
  }
}  



resource "aws_iam_instance_profile" "ec2_ssm_profile2" {
  name = "ec2_ssm_profile3"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "EC2_SSM_Role2"
  assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
            Service = "ec2.amazonaws.com"
            }
        },
        ]
    })
    }

resource "aws_iam_role_policy_attachment" "ec2-ssm-policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create Launch Template
resource "aws_launch_template" "ghostLaunchTemplate2" {
  name = "ghostLaunchTemplate2"
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_ssm_profile2.arn
  }
  image_id = "ami-0c9354388bb36c088"
  instance_type = "t2.micro"
  key_name = "ghost"
  monitoring {
    enabled = true
  }
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Ghost Website"
    }
  }
  user_data = filebase64("${path.module}/user-data.sh")
}

# Create Auto Scaling Policy
resource "aws_autoscaling_policy" "ghost_auto_scaling_policy" {
  name                   = "Ghost Target Tracking Policy"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }  
  target_value = 50.0
  }
  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 300
  autoscaling_group_name = aws_autoscaling_group.ghost_asg2.name
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "ghost_asg2" {
  name = "Ghost ASG2"  
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  launch_template {
    id      = aws_launch_template.ghostLaunchTemplate2.id
    version = "$Latest"
  }
  health_check_grace_period = 150
  health_check_type = "EC2"
  //termination_policies = ["Default"]
  default_cooldown = 300
  tag {
    key                 = "Name"
    value               = "Ghost Website ASG"
    propagate_at_launch = true
  }
  target_group_arns = [aws_lb_target_group.ghost-target-group.arn]
}



# Creating Application LoadBalancer
resource "aws_lb" "external-ghost-alb" {
  name               = "ExternalGhostALB2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2-sg.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}


# Creating ALB Listener
resource "aws_lb_listener" "ghost_listener" {
  load_balancer_arn = aws_lb.external-ghost-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost-target-group.arn
  }
}

#Creating Application LoadBalancer Target Group
resource "aws_lb_target_group" "ghost-target-group" {
  name     = "ALB-Ghost-TG2"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ghostvpc.id
  health_check {
  healthy_threshold = 5
  matcher = 200
  path = "/"
  }
}




# Creating RDS Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "main1a"
  subnet_ids = [aws_subnet.database-subnet-1.id, aws_subnet.database-subnet-2.id]
tags = {
    Name = "RDS subnet group"
  }
}

# Creating RDS Subnet Group
resource "aws_db_subnet_group" "default2" {
  provider = aws.secondary  
  name       = "main2a"
  subnet_ids = [aws_subnet.database-subnet-1a.id, aws_subnet.database-subnet-2a.id]
tags = {
    Name = "RDS subnet group"
  }
}


resource "aws_db_instance" "primary" {
  allocated_storage       = 10
  identifier              = "mydb"
  engine                  = "mysql"
  engine_version          = "8.0.28"
  instance_class          = "db.t3.micro"
  db_name                 = "ghost_database"
  username                = "ghostadmin"
  password                = "ghostadmin"
  backup_retention_period = 7
  storage_encrypted       = true
  skip_final_snapshot     = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.database-sg.id]
}

resource "aws_kms_key" "default" {
  description = "Encryption key for automated backups"
  provider = aws.secondary
}


resource "aws_db_instance" "replica" {
  provider = aws.secondary
  identifier = "mydb-replica"
  # Source database. For cross-region use db_instance_arn
  replicate_source_db    = aws_db_instance.primary.arn
  instance_class          = "db.t3.micro"
  kms_key_id           = aws_kms_key.default.arn
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.database-sg2.id]

  maintenance_window              = "Tue:00:00-Tue:03:00"
  backup_window                   = "03:00-06:00"

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  # Specify a subnet group created in the replica region
  db_subnet_group_name = aws_db_subnet_group.default2.name
}