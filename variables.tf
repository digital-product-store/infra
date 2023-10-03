variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
    type = string
    default = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
    type = string
    default = "10.0.2.0/24"
}

variable "ci_ecr_user_name" {
  type = string
  default = "ci-ecr-user"
}

variable "ci_ecr_group_name" {
  type = string
  default = "ci-ecr-group"
}
