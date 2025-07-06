terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
  }
}

module "pve2_coreos_image" {
  source = "../proxmox-image-uploader"
  image_name   = "fcos-42"
  image_url    = var.image_url
  node_name    = var.node_name
  datastore_id = "local"
}

data "ct_config" "ignition_file" {
  strict = true
  content = templatefile(var.ignition_file, {
    ssh_admin_username   = var.username
    ssh_admin_public_key = file(var.ssh_public_key)
    hostname             = var.hostname
    ip                   = var.ip
  })
}

resource "proxmox_virtual_environment_vm" "coreos_vm" {
  node_name   = var.node_name
  name        = var.hostname

  machine = "q35"

  agent {
    enabled = false
  }

  memory {
    dedicated = var.memory
  }

  disk {
    interface    = "virtio0"
    datastore_id = "local-lvm"
    file_id      = module.pve2_coreos_image.id 
    size         = var.disk_size
  }

  network_device {
    bridge = "vmbr0"
  }

  kvm_arguments = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.ignition_file.rendered, ",", ",,")}'"
}
