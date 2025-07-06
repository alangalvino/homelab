variable "proxmox_endpoint" {
  type      = string
  default   = "https://192.168.50.11:8006/"
  sensitive = true
}

variable "proxmox_username" {
  type      = string
  sensitive = true
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "homelab_username" {
  type      = string
  default   = "root"
  sensitive = true
}

variable "homelab_ssh_private_key" {
  type      = string
  default   = "~/.ssh/homelab"
  sensitive = true
}

variable "homelab_ssh_public_key" {
  type      = string
  default   = "~/.ssh/homelab.pub"
  sensitive = true
}
