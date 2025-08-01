locals {
  temp_dir   = "/tmp/proxmox-disk-image-${uuid()}"
  image_file = "${local.temp_dir}/${var.image_name}.img"
}

resource "null_resource" "download_image" {
  triggers = {
  always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${local.temp_dir}
      curl -L -o ${local.temp_dir}/${var.image_name}.qcow2.xz "${var.image_url}"
      unxz -f ${local.temp_dir}/${var.image_name}.qcow2.xz
      mv ${local.temp_dir}/${var.image_name}.qcow2 ${local.image_file}
    EOT
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "proxmox_virtual_environment_file" "upload_image" {
  content_type = "iso"
  datastore_id = var.storage_pool
  node_name    = var.proxmox_node

  source_file {
    path = local.image_file
  }

  depends_on = [null_resource.download_image]

  lifecycle {
    ignore_changes = all
  }
}

resource "null_resource" "cleanup" {
  triggers = {
    image_path = local.image_file
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf $(dirname ${self.triggers.image_path})"
  }

  depends_on = [proxmox_virtual_environment_file.upload_image]

  lifecycle {
    ignore_changes = all
  }
}
