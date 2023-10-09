resource "helm_release" "request_authentication" {
  name       = "reqauth"
  chart      = "reqauth"
  repository = var.application_helm_repository
  version    = var.request_authentication_version
  namespace  = kubernetes_namespace.istio_system.metadata.0.name

  cleanup_on_fail = true

  set {
    name  = "namespace"
    type  = "string"
    value = kubernetes_namespace.istio_system.metadata.0.name
  }

  set {
    name  = "jwks"
    type  = "string"
    value = var.request_authentication_jwks
  }

  depends_on = [helm_release.istiod]
}
