# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-central-1"
}

variable "config_file_name" {
  description = "Configuration used to put the correct urls into pub/sub."

  type    = string
  default = "config.json"
}

variable "auth0_domain" {}
variable "auth0_client_id" {}
variable "auth0_client_secret" {}
variable "auth0_admin_password" {}
