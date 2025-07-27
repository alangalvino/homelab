terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.80.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
  ssh {
    username    = var.homelab_username
    private_key = file(var.homelab_ssh_private_key)
  }
}

module "home_assistant_vm" {
  source       = "./modules/proxmox-disk-image-vm"
  hostname     = "home-assistant"
  proxmox_node = "pve3"
  cpu_cores    = 2
  memory       = 6144
  disk_size    = 100
  bios         = "ovmf"
  image_url    = "https://github.com/home-assistant/operating-system/releases/download/15.2/haos_ova-15.2.qcow2.xz"
  # IoT VLAN_ID is 40
  ip_address          = "192.168.40.24"
  network_vlan_id     = 40
  network_mac_address = "02:5f:52:b4:3d:40"
}

module "talos_node_1" {
  source              = "./modules/talos-node"
  proxmox_node        = "pve1"
  hostname            = "talos-controlplane"
  cpu_cores           = 2
  memory              = 4096
  disk_size           = 200
  ip_address          = "192.168.50.21"
  gateway_ip          = "192.168.50.1"
  network_mac_address = "e6:3f:f3:99:40:3d"
}

module "talos_node_2" {
  source              = "./modules/talos-node"
  proxmox_node        = "pve2"
  hostname            = "talos-worker-1"
  cpu_cores           = 2
  memory              = 14336
  disk_size           = 200
  ip_address          = "192.168.50.22"
  gateway_ip          = "192.168.50.1"
  network_mac_address = "b6:1a:77:fb:38:60"
}

module "talos_node_3" {
  source              = "./modules/talos-node"
  proxmox_node        = "pve3"
  hostname            = "talos-worker-2"
  cpu_cores           = 2
  memory              = 6144
  disk_size           = 200
  ip_address          = "192.168.50.23"
  gateway_ip          = "192.168.50.1"
  network_mac_address = "ca:29:05:23:c7:cd"
}
module "talos_cluster" {
  source     = "./modules/talos-cluster"
  depends_on = [module.talos_node_1, module.talos_node_2, module.talos_node_3]

  cluster_name     = "k8s-cluster"
  cluster_endpoint = "192.168.50.21"
  controlplanes    = ["192.168.50.21"]
  workers          = ["192.168.50.22", "192.168.50.23"]
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
}
