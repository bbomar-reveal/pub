terraform {
  required_providers {
    k3d = {
      source = "moio/k3d"
    }
    kubernetes = {
        source =  "hashicorp/kubernetes"
    }
    http = {
        source = "hashicorp/http"
    }
    kubectl = {
      source  = "alekc/kubectl"
    }
    helm    = { source = "hashicorp/helm" }
  }
}