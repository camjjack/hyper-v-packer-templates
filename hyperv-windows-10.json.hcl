# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
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
  default = "${env("hyperv_switchname")}"
}

variable "iso_checksum" {
  type    = string
  default = "f1a4f2176259167cd2c8bf83f3f5a4039753b6cc28c35ac624da95a36e9620fc"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/pr/19041.264.200511-0456.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "output_directory" {
  type    = string
  default = "./output-windows-10/"
}

variable "password" {
  type    = string
  default = "vagrant"
}

variable "ram_size" {
  type    = string
  default = "4096"
}

variable "username" {
  type    = string
  default = "vagrant"
}

variable "vm_name" {
  type    = string
  default = "windows-10"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "autogenerated_1" {
  boot_command                     = ["<tab><enter>", "aaaaaaaaaaaa<enter>", "aaaaaaaaaaaa<enter>", "aaaaaa<wait1ms>aaaaaa<enter>"]
  boot_wait                        = "65s"
  communicator                     = "winrm"
  cpus                             = "${var.cpu}"
  disk_size                        = "${var.disk_size}"
  enable_mac_spoofing              = true
  enable_secure_boot               = true
  enable_virtualization_extensions = true
  generation                       = 2
  guest_additions_mode             = "disable"
  iso_checksum                     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url                          = "${var.iso_url}"
  memory                           = "${var.ram_size}"
  output_directory                 = "${var.output_directory}"
  secondary_iso_images             = ["./windows/iso/floppy.iso"]
  shutdown_command                 = "shutdown /s /f /t 0"
  switch_name                      = "${var.hyperv_switchname}"
  vm_name                          = "${var.vm_name}"
  winrm_password                   = "${var.password}"
  winrm_timeout                    = "4h"
  winrm_username                   = "${var.username}"
}

source "virtualbox-iso" "autogenerated_2" {
  boot_command         = ["<enter><enter><enter><enter><enter><enter>"]
  boot_wait            = "0s"
  communicator         = "winrm"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  floppy_dirs          = ["./windows/floppy"]
  floppy_files         = ["./windows/answer_files/virtualbox/autounattend.xml"]
  guest_additions_mode = "upload"
  guest_os_type        = "Windows10_64"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.ram_size}"
  output_directory     = "${var.output_directory}"
  shutdown_command     = "shutdown /s /f /t 0"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--graphicscontroller", "vboxsvga"], ["modifyvm", "{{ .Name }}", "--accelerate2dvideo", "on"], ["modifyvm", "{{ .Name }}", "--accelerate3d", "off"], ["modifyvm", "{{ .Name }}", "--vram", "128"], ["modifyvm", "{{ .Name }}", "--clipboard", "bidirectional"], ["modifyvm", "{{ .Name }}", "--draganddrop", "bidirectional"], ["modifyvm", "{{ .Name }}", "--usb", "on"], ["modifyvm", "{{ .Name }}", "--monitorcount", "1"]]
  vm_name              = "${var.vm_name}"
  winrm_password       = "${var.password}"
  winrm_timeout        = "4h"
  winrm_username       = "${var.username}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.hyperv-iso.autogenerated_1", "source.virtualbox-iso.autogenerated_2"]

  provisioner "powershell" {
    elevated_password = "${var.password}"
    elevated_user     = "${var.username}"
    environment_vars  = ["SSH_USERNAME=${var.username}"]
    scripts           = ["./windows/scripts/install-chocolatey.ps1", "./windows/scripts/enable-hyperv.ps1", "./windows/scripts/compile-dotnet-assemblies.ps1", "./windows/scripts/defrag.ps1", "./windows/scripts/scrub.ps1"]
  }

  provisioner "powershell" {
    elevated_password = "${var.password}"
    elevated_user     = "${var.username}"
    only              = ["virtualbox-iso"]
    scripts           = ["./windows/scripts/install-virtualbox-guest-additions.ps1"]
  }

  provisioner "powershell" {
    elevated_password = "${var.password}"
    elevated_user     = "${var.username}"
    environment_vars  = ["SSH_USERNAME=${var.username}"]
    scripts           = ["./windows/scripts/install-chocolatey.ps1", "./windows/scripts/compile-dotnet-assemblies.ps1", "./windows/scripts/defrag.ps1", "./windows/scripts/scrub.ps1"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "./${var.box_out_dir}/<no value>-${var.output_name}.box"
  }
}
