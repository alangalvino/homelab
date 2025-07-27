variable "proxmox_node" {
  type      = string
  default   = "pve3"
}

variable "hostname" {
  type      = string
}

variable "cpu_cores" {
  type      = number
  default   = 2
}

variable "cpu_type" {
  type      = string
  default   = "x86-64-v2-AES"
}

variable "memory" {
  type      = number
  default   = 4048
}

variable "disk_size" {
  type      = number
  default   = 32
}

variable "ip_address" {
  type      = string
  default   = null
}

variable "gateway_ip" {
  type      = string
  default   = null
}

variable "network_mac_address" {
  type      = string
}
