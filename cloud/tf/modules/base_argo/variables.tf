variable "cluster_name" {
  type = string
  description = "Name of the cluster, from clusters.yaml"
}

variable "cluster_values" {
  type = any
  description = "Merged cluster entry from clusters.yaml"
}

variable "mkcert_caroot" {
  type = any
  description = "cert"
}