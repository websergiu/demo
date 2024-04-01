resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot    = var.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

resource "aws_security_group" "rds" {
  name_prefix = var.name_prefix
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    #    cidr_blocks = [var.ec2_security_group_id]
    security_groups = ["${var.sg_id}"]
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My database subnet group"
  }
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "16db_password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.password
}






