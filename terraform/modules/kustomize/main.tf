data "kustomization_build" "app_dir" {
  path = var.kustomize_path
}

resource "kustomization_resource" "from_build" {
  for_each = data.kustomization_build.app_dir.ids

  manifest = data.kustomization_build.app_dir.manifests[each.value]
}
