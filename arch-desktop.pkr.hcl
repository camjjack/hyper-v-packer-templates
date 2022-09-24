source "hyperv-vmcx" "arch-desktop" {
  clone_from_vmcx_path = var.arch_output_directory
  cpus                 = var.cpu
  enable_secure_boot   = false
  memory               = var.ram_size
  output_directory     = var.arch_desktop_output_directory
  shutdown_command     = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password         = var.password
  ssh_username         = var.username
  switch_name          = var.hyperv_switchname
  vm_name              = "${var.arch_vm_name}-desktop"
  vlan_id              = var.hyperv_vlan_id
}

build {
  sources = ["source.hyperv-vmcx.arch-desktop"]

  provisioner "shell" {
    environment_vars  = ["SSH_USERNAME=${var.username}"]
    execute_command   = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/arch/update.sh", "${path.root}/scripts/arch/zsh.sh", "${path.root}/scripts/arch/desktop.sh", "${path.root}/scripts/arch/enhanced-session-mode.sh"]
  }

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    script          = "${path.root}/scripts/arch/cleanup.sh"
  }

  post-processor "vagrant" {
    output = "${path.root}/${var.box_out_dir}/${source.type}-${var.arch_vm_name}-desktop.box"
  }
}