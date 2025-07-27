variable "image_name" {
  description = "Name of the .qcow2.xz image"
  type        = string
  default     = "some-disk-image"
}

variable "image_url" {
  description = "URL of the .qcow2.xz image"
  type        = string
}

variable "proxmox_node" {
  description = "Proxmox node to upload the image to"
  type        = string
}

variable "storage_pool" {
  description = "Datastore ID on the target node"
  type        = string
  default     = "local"
}
