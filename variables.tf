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

variable "private_subnet_4_cidr" {
  type = string
  default = "10.0.6.0/24"
}

variable "private_subnet_4_az" {
  type = string
  default = "eu-west-1a"
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

variable "product_uploads_s3_bucket_name" {
  type = string
  default = "product-uploads--1a0f59f0-d98d-437f-98d0-1ccac9e2d1d2"
}

variable "product_db_postgres_version" {
  type = string
  default = "15.4"
}

variable "product_db_postgres_param_group" {
  type = string
  default = "default.postgres15"
}

variable "product_db_identifier" {
  type = string
  default = "product-db-0"
}

variable "product_db_username" {
  type = string
  default = "postgres"
}

variable "product_db_password" {
  type = string
  default = "postgres"
}

variable "product_db_name" {
  type = string
  default = "postgres"
}

variable "application_helm_repository" {
  type = string
  default = "https://digital-product-store.github.io/helm_charts/"
}

variable "request_authentication_version" {
  type = string
  default = "0.1.0"
}

variable "request_authentication_jwks" {
  type = string
  default = "eyJrZXlzIjogW3sia3R5IjogIlJTQSIsIm4iOiAiMHJyN0FzZFEzSDVxQUNaa1ZaSV9EUkFTd0FScnZEZ0F4aUdaZ09udGRvWHJBVk5Qb3c4Z3dfYmZrU2psb1NfV1YxNnRvWGpKRWZaT0NCR0ROcFcyT1Q5cUFkaFJRQzBvOE5jOTB5b2FoQmtodjlaYWFJd1lCakhCXzZRN3JOTkxya2tqQ20xcGpFbU1ZeS1nWWNKVm1fRmdDUjItZ0lFUjZFSW5YQW1IMDhxWEd1al8weUhBc2pmTjc5TXpDY19oV09icllBUWVTZllVVDV3SGVOZ01jbExGemx5cFNRb0hGNGpOQWVaSTZ2M0swOE9SeDdMT3AtQXV0STFmR0g4dVRuRXNDTGc4ZjJCNHhIc1A5VnE4bmJuZk9BY3FCVkdFWFFnNHVDQ2JncWRhNWJReVpMQmtmSFR5NnJoVkdxemxGcVdOd2RidFh2TUVTbXpXdmh3QnR3IiwiZSI6ICJBUUFCIiwiYWxnIjogIlJTMjU2In1dfQ=="
}
