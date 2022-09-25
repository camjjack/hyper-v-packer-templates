variable "vyos_output_name" {
  type    = string
  default = "vyos"
}

variable "vyos_username" {
  type    = string
  default = "vyos"
}

variable "vyos_vm_name" {
  type    = string
  default = "vyos"
}

variable "vyos_iso_checksum" {
  type    = string
  default = "796cd4a4c8bfa2ecdbeab0cce1e6bee1bd8cb0f8e01816c1a29d397a5025f8d3"
}

variable "vyos_iso_url" {
  type    = string
  default = "https://s3-us.vyos.io/rolling/current/vyos-1.4-rolling-202209220743-amd64.iso"
}

variable "vyos_ram_size" {
  type    = string
  default = "512"
}

variable "vyos_disk_size" {
  type    = string
  default = "10000"
}

variable "vyos_ip" {
  type    = string
  default = "172.23.139.1"
}

variable "vyos_host_ip" {
  type    = string
  default = "172.23.128.1"
}

variable "vyos_subnet_range" {
  type    = string
  default = "172.23.128.0/20"
}

variable "vyos_dhcp_start" {
  type    = string
  default = "172.23.139.10"
}

variable "vyos_dhcp_end" {
  type    = string
  default = "172.23.139.200"
}

variable "vyos_dns" {
  type    = string
  default = "1.1.1.1"
}

variable "vyos_output_directory" {
  type    = string
  default = "./output/vyos/"
}

variable "vyos_hyperv_switchname" {
  type    = string
  default = "WSL"
}