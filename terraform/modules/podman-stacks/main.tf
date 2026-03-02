locals {
  ssh_private_key    = pathexpand(var.ssh_private_key)
  ssh_options        = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  stack_files        = fileset(var.stacks_path, "**")
  stacks_hash        = sha256(join("", [for file in local.stack_files : filesha256("${var.stacks_path}/${file}")]))
  stack_names_joined = join(" ", var.stack_names)
}

resource "terraform_data" "install_prerequisites" {
  input = "${var.vm_user}@${var.vm_ip}"

  provisioner "local-exec" {
    command = "ssh ${local.ssh_options} -i \"${local.ssh_private_key}\" \"${var.vm_user}@${var.vm_ip}\" \"sudo apt-get update && sudo apt-get install -y podman podman-compose git qemu-guest-agent && sudo systemctl enable --now qemu-guest-agent && sudo mkdir -p /opt/stacks /srv/pihole/etc-pihole /srv/pihole/etc-dnsmasq.d /srv/homepage/config /srv/deye-dummycloud && if [ -f /etc/systemd/resolved.conf ]; then sudo sed -i -E 's/^#?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf && sudo systemctl restart systemd-resolved || true; fi\""
  }
}

resource "terraform_data" "sync_stacks" {
  input      = local.stacks_hash
  depends_on = [terraform_data.install_prerequisites]

  provisioner "local-exec" {
    command = <<-EOT
      ssh ${local.ssh_options} -i "${local.ssh_private_key}" "${var.vm_user}@${var.vm_ip}" "sudo mkdir -p /opt/stacks && for stack in ${local.stack_names_joined}; do sudo rm -rf /opt/stacks/\$stack; done"
      for stack in ${local.stack_names_joined}; do
        tar -C "${var.stacks_path}" -czf - "$stack" | ssh ${local.ssh_options} -i "${local.ssh_private_key}" "${var.vm_user}@${var.vm_ip}" "sudo tar -xzf - -C /opt/stacks"
      done
    EOT
  }
}

resource "terraform_data" "sync_deye_repo" {
  input      = "${local.stacks_hash}-deye"
  depends_on = [terraform_data.sync_stacks]

  provisioner "local-exec" {
    command = "ssh ${local.ssh_options} -i \"${local.ssh_private_key}\" \"${var.vm_user}@${var.vm_ip}\" \"if [ -d /opt/stacks/deye-dummycloud ]; then if [ -d /opt/stacks/deye-dummycloud/repo/.git ]; then sudo git -C /opt/stacks/deye-dummycloud/repo pull --ff-only; else sudo git clone --depth 1 https://github.com/Hypfer/deye-microinverter-cloud-free.git /opt/stacks/deye-dummycloud/repo; fi; fi\""
  }
}

resource "terraform_data" "stack_services" {
  for_each   = toset(var.stack_names)
  input      = each.value
  depends_on = [terraform_data.sync_deye_repo]

  lifecycle {
    replace_triggered_by = [terraform_data.sync_stacks, terraform_data.sync_deye_repo]
  }

  provisioner "local-exec" {
    command = <<-EOT
      printf '%s\n' \
        '[Unit]' \
        'Description=Podman Compose Stack ${each.value}' \
        'After=network-online.target' \
        'Wants=network-online.target' \
        '' \
        '[Service]' \
        'Type=oneshot' \
        'RemainAfterExit=yes' \
        'WorkingDirectory=/opt/stacks/${each.value}' \
        'ExecStart=/usr/bin/podman-compose up -d' \
        'ExecStop=/usr/bin/podman-compose down' \
        'TimeoutStartSec=0' \
        '' \
        '[Install]' \
        'WantedBy=multi-user.target' | ssh ${local.ssh_options} -i "${local.ssh_private_key}" "${var.vm_user}@${var.vm_ip}" "sudo tee /etc/systemd/system/podman-stack-${each.value}.service >/dev/null"

      ssh ${local.ssh_options} -i "${local.ssh_private_key}" "${var.vm_user}@${var.vm_ip}" "sudo systemctl daemon-reload && sudo systemctl enable --now podman-stack-${each.value}.service"

      ssh ${local.ssh_options} -i "${local.ssh_private_key}" "${var.vm_user}@${var.vm_ip}" "if [ '${each.value}' = 'deye-dummycloud' ]; then sudo /usr/bin/podman-compose -f /opt/stacks/${each.value}/compose.yaml up -d --build; else sudo /usr/bin/podman-compose -f /opt/stacks/${each.value}/compose.yaml pull || true; sudo /usr/bin/podman-compose -f /opt/stacks/${each.value}/compose.yaml up -d; fi"
    EOT
  }
}
