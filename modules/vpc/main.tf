module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name # "intaktoradea-vpc"
  cidr = var.vpc_cidr # "10.0.0.0/16"

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.nat
  enable_vpn_gateway = var.vpn

  tags = {
    Terraform   = "true"
    Environment = "${terraform.workspace}"
  }
}