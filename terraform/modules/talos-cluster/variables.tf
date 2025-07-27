variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
}

variable "talos_version" {
  description = "talos version"
  type        = string
  default     = "v1.10.5"
}

variable "controlplanes" {
  description = "Controlplanes"
  type = list(string)
}

variable "workers" {
  description = "Workers"
  type = list(string)
}
