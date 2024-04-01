module "sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}