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

variable "cpu_type" {
  type      = string
  default   = null
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
  default   = null
}

variable "ip_address" {
  type      = string
  default   = null
}

variable "gateway_ip" {
  type      = string
  default   = null
}

variable "subnet_mask" {
  type      = string
  default   = "24"
}

variable "on_boot" {
  type      = bool
  default   = true
}

variable "startup_order" {
  type      = number
  default   = null
}

variable "startup_up_delay" {
  type      = number
  default   = null
}

variable "startup_down_delay" {
  type      = number
  default   = null
}

variable "cloud_init_username" {
  type      = string
  default   = null
}

variable "cloud_init_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "cloud_init_ssh_keys" {
  type      = list(string)
  default   = []
}

variable "agent_enabled" {
  type      = bool
  default   = true
}
