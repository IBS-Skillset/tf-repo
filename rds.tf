# configured aws provider with proper credentials
provider "aws" {
  region  = "ap-south-1"
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {
  vpc_id = "IBS-RnD-VPG1"
  tags = var.tags
}

# create security group for the webserver
resource "aws_security_group" "webserver_security_group" {
  name        = "webserver security group"
  description = "enable http access on port 80"
  vpc_id      = aws_default_vpc.default_vpc.id
  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = var.tags
}

# create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database security group"
  description = "enable aurora access on port 5432"
  vpc_id      = aws_default_vpc.default_vpc.id
  ingress {
    description      = "aurora access"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.webserver_security_group.id] # configuring database to allow traffic from webserver
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = var.tags
}
# create the subnet group for the rds instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name         = "database-subnets"
  subnet_ids   = ["IBS-RnD-S1b-Private","IBS-RnD-S1a-Private"]
  description  = "subnets for database instance"
  tags = var.tags
}
# create the rds instance
resource "aws_rds_cluster_instance" "aurora_postgresql" {
  cluster_identifier      = "my-aurora-postgresql-cluster"
  instance_class          = "db.r5.large"
  engine                  = "aurora-postgresql"
  engine_version          = var.engine_version
  publicly_accessible     = false
  multi_az                = false
  identifier              = "my-aurora-postgresql-instance"
  username                = var.username
  password                = var.password
  allocated_storage       = var.allocated_storage
  tags                    = var.tags
}

# create the cluster
resource "aws_rds_cluster" "aurora_postgresql_cluster" {
  cluster_identifier      = "my-aurora-postgresql-cluster"
  engine                  = "aurora-postgresql"
  database_name           = var.db_name
  master_username         = var.username
  master_password         = var.password
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database_security_group.id]
  scaling_configuration   = var.scaling_configuration
  tags                    = var.tags
  lifecycle {
    prevent_destroy = true
  }
}





