output "credentials" {
  value     = k3d_cluster.thiscluster.credentials[0]
  sensitive = true
}