terraform {
  backend "s3" {
    bucket     = "sergiuoradeanew"    #bucket name
    access_key = "~/.aws/credentials" # aws credentials path
    key        = "intakt"             # state name
    region     = "us-east-1"
    profile    = "default"
  }
}

provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  region                   = local.var.aws.region
}