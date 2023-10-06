resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name = "istio-ingress"
  }
}

locals {
  istio_helm_repository_url = "https://istio-release.storage.googleapis.com/charts"
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  chart      = "base"
  repository = local.istio_helm_repository_url
  namespace  = kubernetes_namespace.istio_system.metadata.0.name
  version    = var.istio_version

  cleanup_on_fail = true
  force_update    = false

  depends_on = [
    aws_eks_node_group.private_node_group_1,
    kubernetes_namespace.istio_system
  ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  chart      = "istiod"
  repository = local.istio_helm_repository_url
  namespace  = kubernetes_namespace.istio_system.metadata.0.name
  version    = var.istio_version

  cleanup_on_fail = true
  force_update    = false

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  chart      = "gateway"
  repository = local.istio_helm_repository_url
  namespace  = kubernetes_namespace.istio_ingress.metadata.0.name
  version    = var.istio_version

  cleanup_on_fail = true
  force_update    = false

  set {
    name = "service.type"
    type = "string"
    value = "NodePort"
  }

  depends_on = [
    helm_release.istiod,
    kubernetes_namespace.istio_ingress
  ]
}

# enable injection
resource "kubernetes_labels" "istio_injection" {
  api_version = "v1"
  kind = "Namespace"

  metadata {
    name = "default"
  }

  labels = {
    "istio-injection" = "enabled"
  }

  force = true
}
