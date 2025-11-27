variable "project" {}

variable "vpc_id" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}

variable "app_sg_id" {}

variable "instance_type" {}
variable "db_instance_type" {}
variable "keypair" {}

variable "region" {
  type = string
  default = "us-east-1"
}