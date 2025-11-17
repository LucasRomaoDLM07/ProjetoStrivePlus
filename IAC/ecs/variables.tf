variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "lab_role_arn" {
  type = string
}

variable "app_image" {
  type = string
}

variable "db_host" {
  type = string
}
