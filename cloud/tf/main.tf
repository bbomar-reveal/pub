locals {
  raw      = yamldecode(file("${path.root}/../configs/clusters.yaml"))
  defaults = local.raw.defaults

  clusters = {
    for name, c in local.raw.clusters : name => merge(
      local.defaults,
      try(local.raw.clusters[c.from], {}),
      c,
      {
        name   = name
        domain = try(c.domain, "${c["shard-name"]}.${local.defaults["domain-name"]}")
        roles = distinct(concat(
          local.defaults.roles,
          try(local.raw.clusters[c.from].roles, []),
          try(c.roles, [])
        ))
      }
    ) if try(c.enabled, true)
  }
}

data "external" "mkcert" {
  program = ["sh", "-c", "jq -n --arg caroot \"$(mkcert -CAROOT)\" '{caroot: $caroot}'"]
}

module "k3d_interface" {
  source   = "./modules/k3d_interface"
  for_each = local.clusters

  cluster_name      = each.key
  cluster_values    = each.value
}

#module "base_argo" {
#  source  = "./modules/base_argo"
#  for_each = local.clusters
#  providers = {
#    helm    = helm.cluster[each.key]
#    kubectl = kubectl.cluster[each.key]
#  }
#  cluster_name = each.key
#  cluster_values = each .value
#  mkcert_caroot  = data.external.mkcert.result.caroot
#}

output "clusters" {
  value = local.clusters
}