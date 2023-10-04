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
  name = "store-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.store_node_group_iam_document.json
}

## Role - Policy Attachments
resource "aws_iam_role_policy_attachment" "store_node_group_worker_node_policy" {
  role = aws_iam_role.store_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "store_node_group_cni_policy" {
  role = aws_iam_role.store_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "store_node_group_ec2_registry_policy" {
  role = aws_iam_role.store_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Node Group
resource "aws_eks_node_group" "private_node_group_1" {
  cluster_name = aws_eks_cluster.store.name
  node_group_name = "private-node-group-1"
  node_role_arn = aws_iam_role.store_node_group_role.arn

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  capacity_type = "ON_DEMAND"
  instance_types = [ "t3a.small" ]

  scaling_config {
    desired_size = 1
    min_size = 1
    max_size = 1
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.store_node_group_worker_node_policy,
    aws_iam_role_policy_attachment.store_node_group_cni_policy,
    aws_iam_role_policy_attachment.store_node_group_ec2_registry_policy,
   ]
}
