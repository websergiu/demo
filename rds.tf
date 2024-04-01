module "rds" {
  source               = "./modules/rds"
  allocated_storage    = local.var.rds.allocated_storage
  db_name              = local.var.rds.db_name
  engine               = local.var.rds.engine
  engine_version       = local.var.rds.engine_version
  instance_class       = local.var.rds.instance_class
  username             = local.var.rds.username
  password             = local.var.rds.password
  parameter_group_name = local.var.rds.parameter_group_name
  skip_final_snapshot  = local.var.rds.skip_final_snapshot
  sg_id                = module.sg.security_group_id
  vpc_id               = module.vpc.vpc_id
  ec2_security_group_id = module.sg.security_group_id
  subnet_ids            = module.vpc.private_subnet_ids
  db_password           = local.var.rds.db_password
  name_prefix           = local.var.rds.name_prefix
}