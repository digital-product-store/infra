# IAM Role For Cluster
## Document
data "aws_iam_policy_document" "store_iam_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

## Role
resource "aws_iam_role" "store_eks_role" {
  name               = "store-eks-role"
  assume_role_policy = data.aws_iam_policy_document.store_iam_doc.json
}

## Role - Policy Attachment
resource "aws_iam_role_policy_attachment" "store_role_policy" {
  role       = aws_iam_role.store_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Cluster
resource "aws_eks_cluster" "store" {
  name     = "store"
  role_arn = aws_iam_role.store_eks_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.store_role_policy]
}

data "aws_eks_cluster" "store" {
  name = "store"

  depends_on = [aws_eks_cluster.store]
}

data "aws_eks_cluster_auth" "store" {
  name = "store"

  depends_on = [aws_eks_cluster.store]
}

# OpenID
data "tls_certificate" "store" {
  url = aws_eks_cluster.store.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "store_openid" {
  url             = aws_eks_cluster.store.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.store.certificates[0].sha1_fingerprint]
}

# IAM Role for Node Group
## Document
data "aws_iam_policy_document" "store_node_group_iam_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

## Role
resource "aws_iam_role" "store_node_group_role" {
  name               = "store-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.store_node_group_iam_document.json
}

## Role - Policy Attachments
resource "aws_iam_role_policy_attachment" "store_node_group_worker_node_policy" {
  role       = aws_iam_role.store_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "store_node_group_cni_policy" {
  role       = aws_iam_role.store_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "store_node_group_ec2_registry_policy" {
  role       = aws_iam_role.store_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Node Group
resource "aws_eks_node_group" "private_node_group_1" {
  cluster_name    = aws_eks_cluster.store.name
  node_group_name = "private-node-group-1"
  node_role_arn   = aws_iam_role.store_node_group_role.arn

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3a.medium"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.store_node_group_worker_node_policy,
    aws_iam_role_policy_attachment.store_node_group_cni_policy,
    aws_iam_role_policy_attachment.store_node_group_ec2_registry_policy,
  ]
}

# ALB
## IAM Role
### Policy
resource "aws_iam_policy" "alb_controller_policy" {
  name = "alb-controller-iam-policy"
  policy = file("aws-policies/alb-controller-iam-policy.json")
}

### Trust Policy Document
data "aws_iam_policy_document" "alb_controller_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.store_openid.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.store_openid.url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.alb_controller_namespace}:${var.alb_controller_service_account_name}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.store_openid.url, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

### Role
resource "aws_iam_role" "alb_controller_role" {
  name = "store-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_role_policy_doc.json
}

### Role - Policy Attachment
resource "aws_iam_role_policy_attachment" "alb_controller_role_policy_attachment" {
  role = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

## ALB Installation
resource "helm_release" "alb_controller" {
  name = "aws-load-balancer-controller"
  chart = "aws-load-balancer-controller"
  repository = var.alb_controller_chart_repo
  version = var.alb_controller_chart_version
  namespace = var.alb_controller_namespace

  set {
    name  = "clusterName"
    value = aws_eks_cluster.store.name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.alb_controller_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller_role.arn
  }

  set {
    name  = "enableServiceMutatorWebhook"
    value = "false"
  }

  depends_on = [ aws_eks_node_group.private_node_group_1 ]
}
