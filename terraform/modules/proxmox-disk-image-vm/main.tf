terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.80.0"
    }
  }
}

module "disk_image" {
  source = "../proxmox-image-uploader"
  image_url    = var.image_url
  proxmox_node = var.proxmox_node
}

module "proxmox_vm" {
  source = "../proxmox-vm"
  proxmox_node        = var.proxmox_node
  hostname            = var.hostname
  cpu_cores           = var.cpu_cores
  bios                = var.bios
  memory              = var.memory
  image_file_id       = module.disk_image.id 
  disk_size           = var.disk_size
  network_vlan_id     = var.network_vlan_id
  network_mac_address = var.network_mac_address  
  ip_address          = var.ip_address
}
