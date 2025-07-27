variable "hostname" {
  type      = string
}

variable "proxmox_node" {
  type      = string
}

variable "memory" {
  type      = number
}

variable "disk_size" {
  type      = number
}

variable "cpu_cores" {
  type      = number
}

variable "bios" {
  type      = string
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

variable "ip_address" {
  type      = string
  default   = null
}
