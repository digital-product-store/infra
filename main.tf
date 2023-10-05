terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.store.endpoint
  token                  = data.aws_eks_cluster_auth.store.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.store.certificate_authority.0.data)
}
