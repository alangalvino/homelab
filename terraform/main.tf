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
  ip_address          = "192.168.40.40"
  network_vlan_id     = 40
  network_mac_address = "02:5f:52:b4:3d:40"
}

module "container_repo_vm" {
  source              = "./modules/proxmox-disk-image-vm"
  hostname            = "container-repository"
  proxmox_node        = "pve2"
  cpu_cores           = 2
  cpu_type            = "x86-64-v2-AES"
  memory              = 4096
  disk_size           = 64
  bios                = "seabios"
  image_url           = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  ip_address          = "192.168.50.100"
  gateway_ip          = "192.168.50.1"
  network_vlan_id     = null
  network_mac_address = "3a:12:5f:b1:f6:10"
  cloud_init_username = "debian"
  cloud_init_ssh_keys = [trimspace(file(pathexpand(var.homelab_ssh_public_key)))]
  agent_enabled       = false
  on_boot             = true
  startup_order       = 1
}

module "podman_stacks" {
  source          = "./modules/podman-stacks"
  depends_on      = [module.container_repo_vm]
  vm_ip           = "192.168.50.100"
  vm_user         = "debian"
  ssh_private_key = var.homelab_ssh_private_key
  stacks_path     = "${path.root}/../stacks"
  stack_names     = ["pihole", "deye-dummycloud", "homepage"]
}
