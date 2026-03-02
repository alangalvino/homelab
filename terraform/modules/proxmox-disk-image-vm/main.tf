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
  cpu_type            = var.cpu_type
  bios                = var.bios
  agent_enabled       = var.agent_enabled
  on_boot             = var.on_boot
  startup_order       = var.startup_order
  startup_up_delay    = var.startup_up_delay
  startup_down_delay  = var.startup_down_delay
  memory              = var.memory
  image_file_id       = module.disk_image.id 
  disk_size           = var.disk_size
  network_vlan_id     = var.network_vlan_id
  network_mac_address = var.network_mac_address  
  ip_address          = var.ip_address
  gateway_ip          = var.gateway_ip
  subnet_mask         = var.subnet_mask
  cloud_init_username = var.cloud_init_username
  cloud_init_password = var.cloud_init_password
  cloud_init_ssh_keys = var.cloud_init_ssh_keys
}
