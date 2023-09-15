resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "monitoring-platform" = "prometheus"
    }
  }

  lifecycle {
    ignore_changes = [
      # metadata[0].labels,
    ]
  }
}

data "http" "crd_alertmanagerconfigs" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/charts/crds/crds/crd-alertmanagerconfigs.yaml"
}
data "http" "crd_alertmanagers" {
  url = "https://github.com/prometheus-community/helm-charts/raw/main/charts/kube-prometheus-stack/charts/crds/crds/crd-alertmanagers.yaml"
}
data "http" "crd_podmonitors" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/charts/crds/crds/crd-podmonitors.yaml"
}
data "http" "crd_probes" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/charts/crds/crds/crd-probes.yaml"
}
data "http" "crd_prometheuses" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/charts/crds/crds/crd-prometheuses.yaml"
}
data "http" "crd_prometheusrules" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/charts/crds/crds/crd-prometheusrules.yaml"
}

data "http" "crd_servicemonitors" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/charts/crds/crds/crd-servicemonitors.yaml"
}

data "http" "crd_thanosrulers" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/charts/crds/crds/crd-thanosrulers.yaml"
}

resource "kubectl_manifest" "crd_alertmanagerconfigs" {
  yaml_body         = data.http.crd_alertmanagerconfigs.response_body
  server_side_apply = true
}
resource "kubectl_manifest" "crd_alertmanagers" {
  yaml_body         = data.http.crd_alertmanagers.response_body
  server_side_apply = true
}
resource "kubectl_manifest" "crd_podmonitors" {
  yaml_body         = data.http.crd_podmonitors.response_body
  server_side_apply = true
}
resource "kubectl_manifest" "crd_probes" {
  yaml_body         = data.http.crd_probes.response_body
  server_side_apply = true
}
resource "kubectl_manifest" "crd_prometheuses" {
  yaml_body         = data.http.crd_prometheuses.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "crd_prometheusrules" {
  yaml_body         = data.http.crd_prometheusrules.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "crd_servicemonitors" {
  yaml_body         = data.http.crd_servicemonitors.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "crd_thanosrulers" {
  yaml_body         = data.http.crd_thanosrulers.response_body
  server_side_apply = true
}
