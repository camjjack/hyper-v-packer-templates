source "hyperv-iso" "windows" {
  boot_command                     = ["<tab><enter>", "aaaaaaaaaaaa<enter>", "aaaaaaaaaaaa<enter>", "aaaaaa<wait1ms>aaaaaa<enter>"]
  boot_wait                        = "65s"
  communicator                     = "winrm"
  cpus                             = var.cpu
  disk_size                        = var.disk_size
  enable_mac_spoofing              = true
  enable_secure_boot               = true
  enable_virtualization_extensions = var.windows_disable_virtualization ? false : true
  // Requires https://github.com/hashicorp/packer-plugin-hyperv/pull/56 to be merged, or checkout camjjack:enable-tpm and use.
  //enable_tpm                       = true
  generation                       = 2
  guest_additions_mode             = "disable"
  iso_checksum                     = "${var.iso_checksum_type}:${var.windows_iso_checksum}"
  iso_url                          = var.windows_iso_url
  memory                           = var.ram_size
  output_directory                 = var.windows_output_directory
  secondary_iso_images             = ["${path.root}/windows/iso/floppy.iso"]
  shutdown_command                 = "shutdown /s /f /t 0"
  switch_name                      = var.hyperv_switchname
  vlan_id                          = var.hyperv_vlan_id
  vm_name                          = var.windows_vm_name
  winrm_password                   = var.password
  winrm_timeout                    = "4h"
  winrm_username                   = var.username
}

source "virtualbox-iso" "windows" {
  boot_command         = ["<enter><enter><enter><enter><enter><enter>"]
  boot_wait            = "0s"
  communicator         = "winrm"
  cpus                 = var.cpu
  disk_size            = var.disk_size
  floppy_dirs          = ["${path.root}/windows/floppy"]
  floppy_files         = ["${path.root}/windows/answer_files/virtualbox/autounattend.xml"]
  guest_additions_mode = "upload"
  guest_os_type        = "Windows10_64"
  iso_checksum         = "${var.iso_checksum_type}:${var.windows_iso_checksum}"
  iso_url              = var.windows_iso_url
  memory               = var.ram_size
  output_directory     = var.windows_output_directory
  shutdown_command     = "shutdown /s /f /t 0"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--graphicscontroller", "vboxsvga"], ["modifyvm", "{{ .Name }}", "--accelerate2dvideo", "on"], ["modifyvm", "{{ .Name }}", "--accelerate3d", "off"], ["modifyvm", "{{ .Name }}", "--vram", "128"], ["modifyvm", "{{ .Name }}", "--clipboard", "bidirectional"], ["modifyvm", "{{ .Name }}", "--draganddrop", "bidirectional"], ["modifyvm", "{{ .Name }}", "--usb", "on"], ["modifyvm", "{{ .Name }}", "--monitorcount", "1"]]
  vm_name              = var.windows_vm_name
  winrm_password       = var.password
  winrm_timeout        = "4h"
  winrm_username       = var.username
}

build {
  sources = ["source.hyperv-iso.windows", "source.virtualbox-iso.windows"]

  provisioner "powershell" {
    elevated_password = var.password
    elevated_user     = var.username
    environment_vars  = ["SSH_USERNAME=${var.username}"]
    scripts           = ["${path.root}/windows/scripts/install-chocolatey.ps1", "${path.root}/windows/scripts/enable-hyperv.ps1", "${path.root}/windows/scripts/compile-dotnet-assemblies.ps1", "${path.root}/windows/scripts/defrag.ps1", "${path.root}/windows/scripts/scrub.ps1"]
  }

  provisioner "powershell" {
    elevated_password = var.password
    elevated_user     = var.username
    only              = ["virtualbox-iso"]
    scripts           = ["${path.root}/windows/scripts/install-virtualbox-guest-additions.ps1"]
  }

  provisioner "powershell" {
    elevated_password = var.password
    elevated_user     = var.username
    environment_vars  = ["SSH_USERNAME=${var.username}"]
    scripts           = ["${path.root}/windows/scripts/install-chocolatey.ps1", "${path.root}/windows/scripts/compile-dotnet-assemblies.ps1", "${path.root}/windows/scripts/defrag.ps1", "${path.root}/windows/scripts/scrub.ps1"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${path.root}/${var.box_out_dir}/${source.type}-${var.windows_output_name}.box"
  }
}
