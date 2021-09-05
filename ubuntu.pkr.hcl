source "hyperv-iso" "ubuntu" {
  boot_command         = ["<esc><wait1>", "set gfxpayload=keep<enter>", "linux /casper/vmlinuz quiet autoinstall \"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"  ---<enter>",  "initrd /casper/initrd<enter>", "boot<enter>"]
  boot_wait            = "3s"
  communicator         = "ssh"
  cpus                 = var.cpu
  disk_size            = var.disk_size
  enable_secure_boot   = false
  generation           = 2
  guest_additions_mode = "disable"
  http_content         = {
    "/user-data" = templatefile("${path.root}/templates/user-data.pkrtpl.hcl",  {
        username = var.username
        password = var.crypted_password
        hostname = var.vm_name
        locale = var.locale
        keyboard_layout = var.keyboard_layout
      })
    "/meta-data" = ""
  }
  iso_checksum         = "file:${var.iso_checksum_url}"
  iso_url              = var.iso_url
  memory               = var.ram_size
  output_directory     = var.output_directory
  shutdown_command     = "echo '${var.username}' | sudo -S -E shutdown -P now"
  ssh_password         = var.password
  ssh_timeout          = "4h"
  ssh_username         = var.username
  switch_name          = var.hyperv_switchname
  vm_name              = var.vm_name
}

source "virtualbox-iso" "ubuntu" {
  boot_command     = [

    # Make the language selector appear...
    " <up><wait>",
    # ...then get rid of it
    " <up><wait><esc><wait>",

    # Go to the other installation options menu and leave it
    "<f6><wait><esc><wait>",

    # Remove the kernel command-line that already exists
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",

    # Add kernel command-line and start install
    "/casper/vmlinuz ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ",
    "<enter>"
  ]
  boot_wait        = "3s"
  communicator     = "ssh"
  cpus             = "${var.cpu}"
  disk_size        = "${var.disk_size}"
  guest_os_type    = "Ubuntu_64"
  http_content         = {
    "/user-data" = templatefile("${path.root}/templates/user-data.pkrtpl.hcl",  {
        username = var.username
        password = var.crypted_password
        hostname = var.vm_name
        locale = var.locale
        keyboard_layout = var.keyboard_layout
      })
    "/meta-data" = ""
  }
  iso_checksum     = "file:${var.iso_checksum_url}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.ram_size}"
  output_directory = "${var.output_directory}"
  shutdown_command = "echo '${var.username}' | sudo -S -E shutdown -P now"
  shutdown_timeout = "10m"
  ssh_password     = "${var.password}"
  ssh_timeout      = "4h"
  ssh_username     = "${var.username}"
  vboxmanage       = [["modifyvm", "{{ .Name }}", "--graphicscontroller", "vboxsvga"], ["modifyvm", "{{ .Name }}", "--accelerate3d", "on"], ["modifyvm", "{{ .Name }}", "--vram", "128"], ["modifyvm", "{{ .Name }}", "--clipboard", "bidirectional"], ["modifyvm", "{{ .Name }}", "--draganddrop", "bidirectional"], ["modifyvm", "{{ .Name }}", "--usb", "on"], ["modifyvm", "{{ .Name }}", "--monitorcount", "1"]]
  vm_name          = "${var.vm_name}"
}

build {
  sources = ["source.hyperv-iso.ubuntu", "source.virtualbox-iso.ubuntu"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    only            = ["virtualbox-iso"]
    scripts         = ["./scripts/virtualbox.sh"]
  }

  provisioner "shell" {
    environment_vars  = ["SSH_USERNAME=${var.username}", "LOCALE=${var.locale}"]
    execute_command   = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    expect_disconnect = true
    scripts           = ["./scripts/update.sh", "./scripts/vagrant.sh", "./scripts/disable-daily-update.sh", "./scripts/ansible.sh"]
  }

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    pause_before    = "10s"
    script          = "./scripts/cleanup.sh"
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "./${var.box_out_dir}/${source.type}-${var.output_name}.box"
  }
}
