module "ecr" {
  source               = "./modules/ecr"
  name                 = local.var.ecr.name
  image_tag_mutability = local.var.ecr.image_tag_mutability
  scan_on_push         = local.var.ecr.scan_on_push
}