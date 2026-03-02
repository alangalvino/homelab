resource "proxmox_virtual_environment_vm" "proxmox_vm" {
  node_name   = var.proxmox_node
  name        = var.hostname
  on_boot     = var.on_boot

  machine = var.machine
  bios = var.bios

  dynamic "startup" {
    for_each = var.startup_order != null ? [1] : []

    content {
      order      = tostring(var.startup_order)
      up_delay   = var.startup_up_delay != null ? tostring(var.startup_up_delay) : null
      down_delay = var.startup_down_delay != null ? tostring(var.startup_down_delay) : null
    }
  }

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

    dynamic "user_account" {
      for_each = var.cloud_init_username != null ? [1] : []

      content {
        username = var.cloud_init_username
        password = var.cloud_init_password
        keys     = var.cloud_init_ssh_keys
      }
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [initialization]
  }
}
