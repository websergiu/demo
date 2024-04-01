module "cw" {
  source             = "./modules/cloud_watch"
  dashboard_name     = local.var.cw.dashboard_name
  app_log_group_name = module.ecs.app_log_group_name
}