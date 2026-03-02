variable "vm_ip" {
  type = string
}

variable "vm_user" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "stacks_path" {
  type = string
}

variable "stack_names" {
  type = list(string)
}
