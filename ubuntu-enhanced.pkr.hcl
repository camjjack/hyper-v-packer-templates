source "hyperv-vmcx" "ubuntu-enhanced" {
  clone_from_vmcx_path = var.input_directory
  cpus                 = var.cpu
  enable_secure_boot   = false
  memory               = var.ram_size
  output_directory     = var.output_directory
  shutdown_command     = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password         = var.password
  ssh_username         = var.username
  switch_name          = var.hyperv_switchname
  vm_name              = "${var.vm_name}-enhanced"
}

build {
  sources = ["source.hyperv-vmcx.ubuntu-enhanced"]

  provisioner "shell" {
    execute_command   = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/ubuntu/update.sh", "${path.root}/scripts/ubuntu/hyperv-enhanced.sh"]
  }

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    pause_before    = "10s"
    scripts         = ["${path.root}/scripts/ubuntu/hyperv-enhanced-after-reboot.sh", "${path.root}/scripts/ubuntu/cleanup.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${path.root}/${var.box_out_dir}/${source.type}-${var.output_name}.box"
  }
}
