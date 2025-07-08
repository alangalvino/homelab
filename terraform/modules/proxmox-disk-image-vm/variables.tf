variable "hostname" {
  type      = string
}

variable "proxmox_node" {
  type      = string
}

variable "memory" {
  type      = number
}

variable "storage_pool" {
  type      = string
}

variable "disk_size" {
  type      = number
}

variable "cpu_cores" {
  type      = number
}

variable "bios" {
  type      = string
  default   = "ovmf"
}

variable "image_url" {
  type      = string
}

variable "network_mac_address" {
  type      = string
}

variable "network_vlan_id" {
  type      = number
}
