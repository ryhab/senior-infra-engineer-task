resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name
  version    = "9.4.2"
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/loki/charts"
  chart      = "loki-stack"
  namespace  = kubernetes_namespace.logging.metadata.0.name
  version    = "2.4.1"
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name
  version    = "6.43.0"
}
  
