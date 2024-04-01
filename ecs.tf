module "ecs" {
  source                   = "./modules/ecs"
  name                     = local.var.ecs.name
  cluster_name             = local.var.ecs.cluster_name
  capacity_providers       = local.var.ecs.capacity_providers
  base                     = local.var.ecs.base
  weight                   = local.var.ecs.weight
  capacity_provider        = local.var.ecs.capacity_provider
  subnet_ids               = module.vpc.private_subnet_ids
  public_subnet_ids        = module.vpc.public_subnet_ids
  sg_id                    = module.sg.security_group_id #"sg-078fd29ff6b3f66a6" # module.vpc.sg_id   # to be updated with security group module
  assign_public_ip         = local.var.ecs.assign_public_ip
  family                   = local.var.ecs.family
  network_mode             = local.var.ecs.network_mode
  requires_compatibilities = local.var.ecs.requires_compatibilities
  cpu                      = local.var.ecs.cpu
  memory                   = local.var.ecs.memory
  username                 = local.var.ecs.username
  password                 = local.var.ecs.password
  db_name                  = local.var.ecs.db_name
  db_address               = module.rds.db_instance_address
  vpc_id                   = module.vpc.vpc_id
  secret_manager_db_arn    = module.rds.secret_manager_db_arn
}