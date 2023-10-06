variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "public_subnet_1_az" {
  type = string
  default = "eu-west-1a"
}

variable "public_subnet_2_cidr" {
  type = string
  default = "10.0.2.0/24"
}

variable "public_subnet_2_az" {
  type = string
  default = "eu-west-1b"
}

variable "private_subnet_1_cidr" {
  type = string
  default = "10.0.3.0/24"
}

variable "private_subnet_1_az" {
  type = string
  default = "eu-west-1a"
}

variable "private_subnet_2_cidr" {
  type = string
  default = "10.0.4.0/24"
}

variable "private_subnet_2_az" {
  type = string
  default = "eu-west-1b"
}

variable "private_subnet_3_cidr" {
  type = string
  default = "10.0.5.0/24"
}

variable "private_subnet_3_az" {
  type = string
  default = "eu-west-1c"
}

variable "ci_ecr_user_name" {
  type = string
  default = "ci-ecr-user"
}

variable "ci_ecr_group_name" {
  type = string
  default = "ci-ecr-group"
}

variable "istio_chart_repo" {
  type = string
  default = "https://istio-release.storage.googleapis.com/charts"
}

variable "istio_version" {
  type = string
  default = "1.19.1"
}

variable "alb_controller_namespace" {
  type = string
  default = "kube-system"
}

variable "alb_controller_service_account_name" {
  type = string
  default = "alb-controller"
}

variable "alb_controller_chart_repo" {
  type = string
  default = "https://aws.github.io/eks-charts"
}

variable "alb_controller_chart_version" {
  type = string
  default = "1.6.1"
}
