terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
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
  source = "../modules/home-assistant"
  hostname = "home-assistant"
  node_name = "pve3"
  cores = 2
  memory = 6144
  disk_size = 100
  datastore_id = "nfs"
  image_url = "https://github.com/home-assistant/operating-system/releases/download/15.2/haos_ova-15.2.qcow2.xz"
  # Mapped to 192.168.40.25 ip in Unifi
  mac_address = "02:5f:52:b4:3d:40"
}
