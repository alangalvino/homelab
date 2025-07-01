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

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
  ssh {
    username    = var.homelab_root_username
    private_key = file(var.homelab_ssh_private_key)
  }
}

resource "null_resource" "coreos_qcow2" {
  provisioner "local-exec" {
    command = "mv $(podman run --security-opt label=disable --pull=always --rm -v .:/data -w /data quay.io/coreos/coreos-installer:release download  -p qemu -f qcow2.xz -s stable -a x86_64 -d) fcos.qcow2.img"
  }

  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "rm -f fcos.qcow2.img"
  # }
}

resource "proxmox_virtual_environment_file" "coreos_qcow2" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve3"

  depends_on = [null_resource.coreos_qcow2]

  source_file {
    path = "fcos.qcow2.img"
  }
}

data "ct_config" "portainer_server_ignition" {
  strict = true
  content = templatefile("ignition/portainer-server.yml.tftpl", {
    ssh_admin_username   = "root"
    ssh_admin_public_key = file(var.homelab_ssh_public_key)
    hostname             = "portainer-server"
  })
}

resource "proxmox_virtual_environment_vm" "portainer_server" {
  node_name   = "pve1"
  name        = "portainer-server"
  description = "Managed by OpenTofu"

  machine = "q35"

  agent {
    enabled = false
  }

  memory {
    dedicated = 4096
  }

  disk {
    interface    = "virtio0"
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.coreos_qcow2.id
    size         = 32
  }

  network_device {
    bridge = "vmbr0"
  }

  kvm_arguments = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.portainer_server_ignition.rendered, ",", ",,")}'"
}

data "ct_config" "portainer_agent_ignition" {
  strict = true
  content = templatefile("ignition/portainer-agent.yml.tftpl", {
    ssh_admin_username   = "root"
    ssh_admin_public_key = file(var.homelab_ssh_public_key)
    hostname             = "portainer-agent"
  })
}

resource "proxmox_virtual_environment_vm" "portainer_agent" {
  node_name   = "pve3"
  name        = "portainer-agent"
  description = "Managed by OpenTofu"

  machine = "q35"

  agent {
    enabled = false
  }

  memory {
    dedicated = 4096
  }

  disk {
    interface    = "virtio0"
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.coreos_qcow2.id
    size         = 32
  }

  network_device {
    bridge = "vmbr0"
  }

  kvm_arguments = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.portainer_agent_ignition.rendered, ",", ",,")}'"
}
