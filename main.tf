terraform {
  backend "s3" {}

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.61"
    }
  }
}

provider "local" {}
provider "aws" {}

locals {
  non_secret_env_temp = {
    for k, v in var.dream_env : k => try(tostring(v), null)
  }
  non_secret_env = {
    for k, v in local.non_secret_env_temp : k => v if v != null && !startswith(k, "IAM_POLICY_")
  }
  secret_env_temp = {
    for k, v in var.dream_env : k => try(tostring(v.key), null)
  }
  secret_env = {
    for k, v in local.secret_env_temp : k => v if v != null
  }
  
}

data "aws_ssm_parameter" "secrets_env" {
  for_each = local.secret_env
  name     = each.value
  with_decryption = true
}

locals {
  decrypted_secret_env = {
    for k, v in data.aws_ssm_parameter.secrets_env : k => v.value
  }
  env = merge(local.non_secret_env, local.decrypted_secret_env)

  env_vars = join("\n", values({
    for key, value in local.env :
    key => "${key}=${value}"
  }))
}

resource "local_sensitive_file" "dev_vars" {
  filename = "${var.dream_project_dir}/.dev.vars"
  content  = local.env_vars
}
