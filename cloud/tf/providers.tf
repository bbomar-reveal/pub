terraform {
  required_providers {
    k3d = {
      source = "moio/k3d"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source = "alekc/kubectl"
    }
  }
}

provider "k3d" {}

provider "helm" {
  alias    = "cluster"
  for_each = local.clusters

  kubernetes = {
    host                   = try(module.k3d_interface[each.key].credentials.host)
    client_certificate     = try(module.k3d_interface[each.key].credentials.client_certificate)
    client_key             = try(module.k3d_interface[each.key].credentials.client_key)
    cluster_ca_certificate = try(module.k3d_interface[each.key].credentials.cluster_ca_certificate)
  }
}

provider "kubectl" {
  alias    = "cluster"
  for_each = local.clusters

  host                   = try(module.k3d_interface[each.key].credentials.host)
  client_certificate     = try(module.k3d_interface[each.key].credentials.client_certificate)
  client_key             = try(module.k3d_interface[each.key].credentials.client_key)
  cluster_ca_certificate = try(module.k3d_interface[each.key].credentials.cluster_ca_certificate)
  load_config_file       = false
}