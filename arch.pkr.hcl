source "hyperv-iso" "arch" {
  boot_command = ["<enter><wait10><wait10>",
    "curl -o enable-ssh.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/enable-ssh.sh && chmod +x enable-ssh.sh && ./enable-ssh.sh<enter>",
  "curl -o hyperv.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/hyperv.sh && chmod +x hyperv.sh && ./hyperv.sh<enter>"]
  boot_wait                        = "3s"
  communicator                     = "ssh"
  cpus                             = var.cpu
  disk_size                        = var.disk_size
  enable_secure_boot               = false
  generation                       = 2
  enable_virtualization_extensions = false
  enable_dynamic_memory            = true
  http_content = {
    "/enable-ssh.sh" = templatefile("./templates/enable-ssh.sh.pkrtpl.hcl", {
      username = var.username
      password = var.password
    })
    "/hyperv.sh" = file("scripts/arch/hyperv.sh")
  }
  iso_checksum     = "file:${var.arch_iso_checksum_url}"
  iso_url          = var.arch_iso_url
  memory           = var.ram_size
  output_directory = var.arch_output_directory
  shutdown_command = "echo '${var.username}' | sudo -S -E shutdown -P now"
  ssh_password     = var.password
  ssh_timeout      = "4h"
  ssh_username     = var.username
  switch_name      = var.hyperv_switchname
  vm_name          = var.arch_vm_name
}

build {
  sources = ["source.hyperv-iso.arch"]

  provisioner "file" {
    content = templatefile("./templates/install-chroot.sh.pkrtpl.hcl", {
      timezone_region = var.timezone_region
      timezone_city   = var.timezone_city
      locale          = var.locale
      keymap          = var.keyboard_layout
      hostname        = var.arch_hostname
      username        = var.username
      password        = var.password
    })
    destination = "/tmp/install-chroot.sh"
  }

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    inline = [templatefile("./templates/install.sh.pkrtpl.hcl", {
      disk      = "/dev/sda"
      swap_size = var.ram_size * 2
    })]
    expect_disconnect = true
  }

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    scripts         = ["${path.root}/scripts/arch/ansible.sh", "${path.root}/scripts/arch/aur.sh"]
  }

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    script          = "${path.root}/scripts/arch/cleanup.sh"
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${path.root}/${var.box_out_dir}/${source.type}-${var.arch_vm_name}.box"
  }
}
