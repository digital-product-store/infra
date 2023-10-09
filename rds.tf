resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_3.id, aws_subnet.private_subnet_4.id]
  tags = {
    "Name" = "rds-subnet-group"
  }
}

resource "aws_security_group" "product_db_sg" {
  name   = "product_db_security_group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_eks_cluster.store.vpc_config[0].cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "product_db" {
  engine                              = "postgres"
  engine_version                      = var.product_db_postgres_version
  identifier                          = var.product_db_identifier
  username                            = var.product_db_username
  password                            = var.product_db_password
  instance_class                      = "db.t3.micro"
  storage_type                        = "gp2"
  allocated_storage                   = 20
  max_allocated_storage               = 0
  db_subnet_group_name                = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids              = [aws_security_group.product_db_sg.id]
  iam_database_authentication_enabled = true
  db_name                             = var.product_db_name
  parameter_group_name                = var.product_db_postgres_param_group
}

output "product_db_endpoint" {
  value = aws_db_instance.product_db.endpoint
}

# TODO: GRANT rds_iam TO postgres;