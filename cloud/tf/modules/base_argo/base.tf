resource "helm_release" "argocd" {
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
  version          = "10.10.5" # pin this; the HelmChart CR was floating on latest
  namespace        = "argocd"
  create_namespace = true

  values = [yamlencode({
    global = {
      domain = "argocd.${var.cluster_values.shard-name}.${var.cluster_values.domain-name}"
    }

    configs = {
      params = {
        "server.insecure" = true
      }
    }

    server = {
      service = {
        type = "ClusterIP"
      }
      ingress = {
        enabled          = true
        ingressClassName = "traefik"
        path             = "/"
        pathType         = "Prefix"
      }
    }
  })]    
}

data "http" "baseapps" {
    url = "https://raw.githubusercontent.com/bbomar-reveal/pub/refs/heads/main/base/appgroups/baseapps.yaml"
}

resource "kubectl_manifest" "supplamental_apps" {
    #manifest = yamldecode(data.http.baseapps.response_body)
    yaml_body = data.http.baseapps.response_body
    server_side_apply = true
    depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "in-cluster" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: in-cluster
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
    cluster: ${var.cluster_values.shard-name}
    domainName: ${var.cluster_values.shard-name}.${var.cluster_values.domain-name}
  annotations:
    domain: ${var.cluster_values.shard-name}.${var.cluster_values.domain-name}
type: Opaque
stringData:
  name: in-cluster
  server: https://kubernetes.default.svc
YAML
}

resource "kubectl_manifest" "cert_manager_ns" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata   = { name = "cert-manager" }
  })
}

resource "kubectl_manifest" "mac_ca" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    type       = "kubernetes.io/tls"
    metadata = {
      name      = "mac-ca"
      namespace = "cert-manager"
    }
    data = {
      "tls.crt" = filebase64("${var.mkcert_caroot}/rootCA.pem")
      "tls.key" = filebase64("${var.mkcert_caroot}/rootCA-key.pem")
    }
  })

  sensitive_fields = ["data"]
  depends_on       = [kubectl_manifest.cert_manager_ns]
}