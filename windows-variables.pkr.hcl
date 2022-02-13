variable "windows_iso_checksum" {
  type    = string
  default = "E8B1D2A1A85A09B4BF6154084A8BE8E3C814894A15A7BCF3E8E63FCFA9A528CB"
}

variable "windows_iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/sg/22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "windows_output_directory" {
  type    = string
  default = "./output/windows/"
}

variable "windows_vm_name" {
  type    = string
  default = "windows"
}

variable "windows_disable_virtualization" {
  default = false
}

variable "windows_output_name" {
  type    = string
  default = "windows"
}
