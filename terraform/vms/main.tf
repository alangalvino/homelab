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

module "portainer_agent_vm" {
  source = "../modules/coreos"
  hostname = "portainer-agent"
  ignition_file = "./ignition/portainer-agent.yml.tftpl"
  username = var.homelab_username
  ssh_public_key = var.homelab_ssh_public_key
  node_name = "pve2"
  memory = 1096
  disk_size = 30
  image_url = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/42.20250609.3.0/x86_64/fedora-coreos-42.20250609.3.0-qemu.x86_64.qcow2.xz"
  ip = "192.168.50.21"
}

module "portainer_server_vm" {
  source = "../modules/coreos"
  hostname = "portainer-server"
  ignition_file = "./ignition/portainer-server.yml.tftpl"
  username = var.homelab_username
  ssh_public_key = var.homelab_ssh_public_key
  node_name = "pve2"
  memory = 1096
  disk_size = 30
  image_url = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/42.20250609.3.0/x86_64/fedora-coreos-42.20250609.3.0-qemu.x86_64.qcow2.xz"
  ip = "192.168.50.20"
}
