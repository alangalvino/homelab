resource "proxmox_virtual_environment_vm" "proxmox_vm" {
  node_name   = var.proxmox_node
  name        = var.hostname

  machine = var.machine
  bios = var.bios

  cpu {
    cores = var.cpu_cores
    type = var.cpu_type
  }

  agent {
    enabled = var.agent_enabled
  }

  memory {
    dedicated = var.memory
  }

  efi_disk {
    datastore_id = var.bios == "ovmf" ? var.efi_storage_pool : null
  }

  disk {
    datastore_id = var.storage_pool
    size         = var.disk_size
    interface    = var.disk_interface
    file_id      = var.image_file_id 
  }

  network_device {
    bridge      = var.network_bridge
    vlan_id     = var.network_vlan_id
    mac_address = var.network_mac_address 
  }

  initialization {
    ip_config {
      ipv4 {
	address = var.ip_address != null ? "${var.ip_address}/${var.subnet_mask}" : null
	gateway = var.gateway_ip != null ? var.gateway_ip : null
      }
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [initialization]
  }
}
