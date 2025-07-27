terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.80.0"
    }
  }
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.10.5/nocloud-amd64.iso"
  file_name    = "talos-no-cloud-with-qemu-agent-v1.10.5.iso" 
  overwrite    = true
}

module "proxmox_vm" {
  source = "../proxmox-vm"
  proxmox_node        = var.proxmox_node
  hostname            = var.hostname
  cpu_cores           = var.cpu_cores
  memory              = var.memory
  image_file_id       = proxmox_virtual_environment_download_file.talos_image.id 
  disk_size           = var.disk_size
  ip_address          = var.ip_address
  gateway_ip          = var.gateway_ip
  network_mac_address = var.network_mac_address
  cpu_type            = var.cpu_type
}
