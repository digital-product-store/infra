resource "kubernetes_ingress_v1" "istio_ingress" {
  metadata {
    name      = "istio-ingress"
    namespace = "istio-ingress"

    annotations = {
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz/ready"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/target-type"          = "instance"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = "istio-ingress"
              port {
                number = 15021
              }
            }
          }
          path      = "/healthz/ready"
          path_type = "Prefix"
        }

        path {
          backend {
            service {
              name = "istio-ingress"
              port {
                number = 80
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }

  depends_on = [helm_release.istio_ingress]
}
