module "disk_image" {
  source = "../proxmox-image-uploader"
  image_url    = var.image_url
  proxmox_node = var.proxmox_node
  storage_pool = var.storage_pool
}

module "proxmox_vm" {
  source = "../proxmox-vm"
  proxmox_node        = var.proxmox_node
  hostname            = var.hostname
  cpu_cores           = var.cpu_cores
  bios                = var.bios
  memory              = var.memory
  efi_storage_pool    = var.storage_pool
  storage_pool        = var.storage_pool
  image_file_id       = module.disk_image.id 
  disk_size           = var.disk_size
  network_vlan_id     = var.network_vlan_id
  network_mac_address = var.network_mac_address  
}

# resource "proxmox_virtual_environment_haresource" "ha_ha_vm" {
#   resource_id  = "vm:${proxmox_vm.id}"
#   comment = "Home Assistant high availability"
#   max_relocate = 1
#   max_restart = 1
# }


# resource "proxmox_virtual_environment_haresource" "ha_ha_vm" {
#   resource_id  = "vm:${proxmox_vm.id}"
#   comment = "Home Assistant high availability"
#   max_relocate = 1
#   max_restart = 1
# }
