source "hyperv-vmcx" "ubuntu-desktop" {
  clone_from_vmcx_path = var.input_directory
  cpus                 = var.cpu
  enable_secure_boot   = false
  memory               = var.ram_size
  output_directory     = var.output_directory
  shutdown_command     = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password         = var.password
  ssh_username         = var.username
  switch_name          = var.hyperv_switchname
  vm_name              = "${var.vm_name}-desktop"
}

source "virtualbox-ovf" "ubuntu-desktop" {
  output_directory = var.output_directory
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  shutdown_timeout = "10m"
  source_path      = "${var.input_directory}/${var.input_name}.ovf"
  ssh_password     = var.password
  ssh_username     = var.username
  vm_name          = var.vm_name
}

build {
  sources = ["source.hyperv-vmcx.ubuntu-desktop", "source.virtualbox-ovf.ubuntu-desktop"]

  provisioner "shell" {
    environment_vars  = ["SSH_USERNAME=${var.username}"]
    execute_command   = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash {{ .Path }}"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/ubuntu/update.sh", "${path.root}/scripts/ubuntu/desktop.sh", "${path.root}/scripts/ubuntu/cleanup.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${path.root}/${var.box_out_dir}/${source.type}-${var.output_name}.box"
  }
}
