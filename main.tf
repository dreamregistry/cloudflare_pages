terraform {
  backend "s3" {}

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "local" {}

locals {
  env_vars = join("\n", values({
    for key, value in var.dream_env :
    key => "${key}=${value}"
  }))
}

resource "local_sensitive_file" "dev_vars" {
  filename = "${var.dream_project_dir}/.dev.vars"
  content  = local.env_vars
}
