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
  default = "44947c67b0af34a2e589ebc106b92691dd4e611b141900c38c6c3b3ae6d4865d"
}

variable "vyos_iso_url" {
  type    = string
  default = "https://s3.amazonaws.com/s3-us.vyos.io/snapshot/vyos-1.3.0-rc6/vyos-1.3.0-rc6-amd64.iso"
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
  default = "172.19.139.1"
}

variable "vyos_host_ip" {
  type    = string
  default = "172.19.128.1"
}

variable "vyos_subnet_range" {
  type    = string
  default = "172.19.128.0/20"
}

variable "vyos_dhcp_start" {
  type    = string
  default = "172.19.139.10"
}

variable "vyos_dhcp_end" {
  type    = string
  default = "172.19.139.200"
}

variable "vyos_dns" {
  type    = string
  default = "1.1.1.1"
}