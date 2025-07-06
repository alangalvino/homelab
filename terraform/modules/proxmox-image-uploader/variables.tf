variable "image_name" {
  description = "Name of the .qcow2.xz image"
  type        = string
}

variable "image_url" {
  description = "URL of the .qcow2.xz image"
  type        = string
}

variable "node_name" {
  description = "Proxmox node to upload the image to"
  type        = string
}

variable "datastore_id" {
  description = "Datastore ID on the target node"
  type        = string
}
