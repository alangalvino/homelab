terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}

module "home_assistant_image" {
  source = "../proxmox-image-uploader"
  image_name   = "ha-image"
  image_url    = var.image_url
  node_name    = var.node_name
  datastore_id = var.datastore_id
}

resource "proxmox_virtual_environment_vm" "ha_vm" {
  node_name   = var.node_name
  name        = var.hostname

  machine = "q35"
  bios = "ovmf"

  cpu {
    cores = var.cores
  }

  agent {
    enabled = false
  }

  memory {
    dedicated = var.memory
  }

  efi_disk {
    datastore_id = var.datastore_id
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = module.home_assistant_image.id 
    size         = var.disk_size
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    # Unifi VLAN for IoT devices
    vlan_id = 40
    mac_address = var.mac_address  
  }
}

resource "proxmox_virtual_environment_haresource" "ha_ha_vm" {
  resource_id  = "vm:${proxmox_virtual_environment_vm.ha_vm.vm_id}"
  comment = "Home Assistant high availability"
  max_relocate = 1
  max_restart = 1
}
