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