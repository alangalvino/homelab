output "kubeconfig" {
  value     = module.k8s_cluster.kubeconfig
  sensitive = true
}

output "talosconfig" {
  value     = module.k8s_cluster.talosconfig
  sensitive = true
}
