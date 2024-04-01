module "vpc" {
  source          = "./modules/vpc"
  vpc_name        = local.var.vpc.name
  vpc_cidr        = local.var.vpc.cidr
  nat             = local.var.vpc.nat
  vpn             = local.var.vpc.vpn
  azs             = local.var.vpc.azs
  private_subnets = local.var.vpc.private_subnets
  public_subnets  = local.var.vpc.public_subnets
}