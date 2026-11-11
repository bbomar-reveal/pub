locals {
  http_port = 8085 + var.cluster_values.numId
  https_port = 8448 + var.cluster_values.numId
  api_port = 6555 + var.cluster_values.numId
}

locals {
  k3d_registries = {
    "docker.io"       = "k3d-docker-io"
    "ghcr.io"         = "k3d-ghcr-io"
    "quay.io"         = "k3d-quay-io"
    "registry.k8s.io" = "k3d-registry-k8s-io"
  }

  k3d_registries_yaml = yamlencode({
    mirrors = {
      for upstream, name in local.k3d_registries :
      upstream => { endpoint = ["http://${name}:5000"] }
    }
  })
}

resource "k3d_cluster" "thiscluster" {
  name = var.cluster_name
  servers = var.cluster_values.ctlNodesNum
  agents = var.cluster_values.wrkNodesNum
  network = "kubenet"
  image = "rancher/k3s:${var.cluster_values.k3s_version}"
  
  registries {
    use = [
      "k3d-docker-io:5001",
      "k3d-ghcr-io:5002",
      "k3d-quay-io:5003",
      "k3d-registry-k8s-io:5004",
    ]
    config = local.k3d_registries_yaml
  }

  port {
    host_port   = local.http_port
    container_port = 80
    node_filters = [ "loadbalancer"]
  }

  port {
    host_port   = local.https_port
    container_port = 443
    node_filters = [ "loadbalancer"]
  }

  kube_api {
    host_port = local.api_port
  }
  kubeconfig {
    update_default_kubeconfig = true
    switch_current_context    = false
  }
  k3s {
    extra_args {
      arg          = "--node-label=bob/sharedservices=${var.cluster_values.shared-services}"
      node_filters = ["server:*", "agent:*"]
    }
    extra_args {
      arg          = "--node-label=bob/domainName=${var.cluster_values.domain-name}"
      node_filters = ["server:*", "agent:*"]
    }
    extra_args {
      arg          = "--node-label=bob/cluster=${var.cluster_values.shard-name}"
      node_filters = ["server:*", "agent:*"]
    }
  }
}