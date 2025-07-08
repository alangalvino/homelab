variable "proxmox_node" {
  type      = string
  default   = "pve3"
}

variable "hostname" {
  type      = string
}

variable "machine" {
  type      = string
  default   = "q35"
}

variable "bios" {
  type      = string
  default   = "seabios"

  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "Bios must be one of: seabios or ovmf."
  }
}

variable "cpu_cores" {
  type      = number
  default   = 2
}

variable "agent_enabled" {
  type      = bool
  default   = true
}

variable "memory" {
  type      = number
  default   = 4048
}

variable "efi_storage_pool" {
  type      = string
  default   = null
}

variable "storage_pool" {
  type      = string
  default   = "nfs"
}

variable "disk_size" {
  type      = number
  default   = 32
}

variable "disk_interface" {
  type      = string
  default   = "scsi0"
}

variable "image_file_id" {
  type      = string
}

variable "network_bridge" {
  type      = string
  default   = "vmbr0"
}

variable "network_vlan_id" {
  type      = number
  default   = null
}

variable "network_mac_address" {
  type      = string
  default   = null
}

variable "ip_address" {
  type      = string
  default   = null
}

variable "subnet_mask" {
  type      = string
  default   = "24"
}
