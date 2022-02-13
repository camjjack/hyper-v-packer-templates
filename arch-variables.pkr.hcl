variable "arch_iso_checksum_url" {
  type    = string
  default = "http://ftp.iinet.net.au/pub/archlinux/iso/2022.01.01/sha1sums.txt"
}

variable "arch_iso_url" {
  type    = string
  default = "http://ftp.iinet.net.au/pub/archlinux/iso/2022.01.01/archlinux-2022.01.01-x86_64.iso"
}

variable "arch_output_directory" {
  type    = string
  default = "./output/arch/"
}

variable "arch_desktop_output_directory" {
  type    = string
  default = "./output/arch-desktop/"
}

variable "arch_hostname" {
  type    = string
  default = "archiso"
}

variable "arch_vm_name" {
  type    = string
  default = "arch"
}