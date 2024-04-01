locals {
  default_vars          = {}
  tfsettingsfile        = "./environment/${terraform.workspace}.yaml"
  tfsettingsfilecontent = fileexists(local.tfsettingsfile) ? file(local.tfsettingsfile) : " NoSettingsFileFound: true"
  tfworkspacesettings   = yamldecode(local.tfsettingsfilecontent)
  var                   = merge(local.default_vars, local.tfworkspacesettings)
}
