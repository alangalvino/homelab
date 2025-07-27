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

resource "proxmox_virtual_environment_haresource" "home_assistant_high_availability" {
  resource_id  = "vm:${module.home_assistant_vm.id}"
  comment = "Home Assistant HA"
  max_relocate = 1
  max_restart = 1
}
