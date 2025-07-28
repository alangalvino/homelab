module "talos_cluster" {
  source     = "../talos-cluster"

  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  controlplanes    = var.controlplanes
  workers          = var.workers
}

resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb-system"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = "metallb-system"
  depends_on = [kubernetes_namespace.metallb]
}

resource "terraform_data" "metallb_configs" {
  depends_on = [helm_release.metallb]
  input      = file("./metallb-config.yaml")
  provisioner "local-exec" {
    when        = destroy
    command     = "echo '${self.input}' | kubectl delete -f -"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "terraform_data" "apply_metallb_configs" {
  depends_on = [terraform_data.metallb_configs]
  lifecycle {
    replace_triggered_by = [terraform_data.metallb_configs]
  }
  provisioner "local-exec" {
    command     = "echo '${terraform_data.metallb_configs.output}' | kubectl apply -f -"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"

    labels = {
      "pod-security.kubernetes.io/enforce"         = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "latest"
      "pod-security.kubernetes.io/audit"           = "privileged"
      "pod-security.kubernetes.io/warn"            = "privileged"
    }

  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = "longhorn-system"
  depends_on = [kubernetes_namespace.longhorn]
}
