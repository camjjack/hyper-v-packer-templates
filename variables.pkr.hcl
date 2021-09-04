variable "box_out_dir" {
  type    = string
  default = "./dist/"
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "200000"
}

variable "hyperv_switchname" {
  type    = string
  default = "Default Switch"
}

variable "initrd" {
  type    = string
  default = "/casper/initrd"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_checksum_url" {
  type    = string
  default = "https://releases.ubuntu.com/20.04/SHA256SUMS"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso"
}

#variable "keyboard_layout" {
#  type    = string
#  default = "USA"
#}

variable "keyboard_layout" {
  type    = string
  default = "us"
}

variable "locale" {
  type    = string
  default = "en_US.UTF-8"
}

variable "output_directory" {
  type    = string
  default = "./output-ubuntu-20.04/"
}

variable "output_name" {
  type    = string
  default = "ubuntu-focal"
}

variable "password" {
  type    = string
  default = "vagrant" #vagrant
}

variable "crypted_password" {
  type    = string
  description = "openssl passwd -6 password. must match password from above"
  default = "$6$5rFpim1KqZfBwzhD$XIwSTmg2rjrzFSX9qcBUs2atswKmwHvMz4RZS8Cmb7gMf5ZmSpcv7q.G3.FW/K5adDoc6BwQSaGxuyBd25gl21" #vagrant
}

variable "ram_size" {
  type    = string
  default = "2048"
}

variable "username" {
  type    = string
  default = "vagrant"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-focal"
}

variable "vmlinuz" {
  type    = string
  default = "/casper/vmlinuz"
}
variable "input_directory" {
  type    = string
  default = "./output-ubuntu-20.04/"
}
variable "input_name" {
  type    = string
  default = "ubuntu-20.04"
}
