## Variables
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

# VM generic
variable "vm_cpu_sockets" {
  type    = number
  default = "1"
}

variable "vm_cpu_cores" {
  type    = number
  default = "2"
}

variable "vm_cpu_type" {
  type    = string
  default = "host"
}

variable "vm_mem_size" {
  type    = number
  default = "4096"
}

variable "vm_os_disk_storage_pool" {
  type    = string
  default = "proxmox"
}

variable "vm_os_disk_size" {
  type    = string
  default = "20G"
}

variable "vm_network_adapters_model" {
  type    = string
  default = "virtio"
}

variable "vm_network_adapters_bridge" {
  type    = string
  default = "vmbr0"
}
