packer {
  required_plugins {
    #hyperv = {
    #  version = ">= 1.0.2"
    #  source  = "github.com/hashicorp/hyperv"
    #}
  }
}

source "hyperv-iso" "vyos" {
  boot_command         = [
                          # Login to live ISO
                          "<enter><wait3><enter><wait20>",
                          # Login
                          "vyos<enter><wait>vyos<enter><wait>", 
                          # Start the installation
                          "install image<enter><wait3>",
                          # Would you like to continue (Yes/No): (Yes):
                          "<enter><wait3>",
                          # Partition (Auto/Parted/Skip) (Auto):
                          "<enter><wait3>",
                          # Install the image on? (sda):
                          "<enter>",
                          # Continue? (Yes/No) (No):
                          "Yes<enter><wait3>",
                          # How big of a root partition should I create?
                          "<enter><wait20>",
                          # What would you like to name this image?
                          "<enter><wait3>",
                          # Which one should I copy to sda?
                          "<enter>",
                          # Enter password for user vyos:
                          "${var.password}<enter>",
                          # Retype paswword for user vyos:
                          "${var.password}<enter><wait3>",
                          # Which drive should GRUB modify the boot partition on? (sda):
                          "<enter><wait5>",
                          # Reboot
                          "reboot<enter><wait3>y<enter>",
                          # Wait for reboot
                          "<wait30>",
                          # Login
                          "vyos<enter><wait3>",
                          "${var.password}<enter><wait3>",
                          # Enter configuration mode
                          "configure<enter><wait3>",
                          # Configure IP
                          "set interfaces ethernet eth0 address '${var.vyos_ip}/20'<enter>",
                          # Configure route
                          "set protocols static route 0.0.0.0/0 next-hop '${var.vyos_host_ip}'<enter>",
                          # Set DNS
                          "set system name-server ${var.vyos_dns}<enter>",
                          # Enable SSH
                          "set service ssh port '22'<enter>",
                          # Commit configuration
                          "commit<enter><wait3>",
                          # Save configuration
                          "save<enter>"
                          ]
  boot_wait            = "3s"
  communicator         = "ssh"
  cpus                 = 1
  disk_size            = var.vyos_disk_size
  enable_secure_boot   = false
  generation           = 2
  guest_additions_mode = "disable"
  iso_checksum     = var.vyos_iso_checksum
  iso_url          = var.vyos_iso_url
  memory           = var.vyos_ram_size
  output_directory = var.output_directory
  shutdown_command = "echo '${var.username}' | sudo -S -E shutdown -P now"
  ssh_password     = var.password
  ssh_timeout      = "4h"
  ssh_username     = var.vyos_username
  switch_name      = var.hyperv_switchname
  vm_name          = var.vyos_vm_name
}

build {
  sources = ["source.hyperv-iso.vyos"]

  provisioner "shell" {
    environment_vars = ["RANGE=${var.vyos_subnet_range}", "DEFAULT_ROUTER=${var.vyos_host_ip}", "DHCP_START=${var.vyos_dhcp_start}", "DHCP_END=${var.vyos_dhcp_start}"]
    execute_command  = "{{ .Vars }} sg vyattacfg -c {{ .Path }}"
    scripts          = ["${path.root}/scripts/vyos/dhcp.sh", "${path.root}/scripts/vyos/vagrant.sh"]
  }
  
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E bash {{ .Path }}"
    script          = "${path.root}/scripts/vyos/cleanup.sh"
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${path.root}/${var.box_out_dir}/${source.type}-${var.vyos_output_name}.box"
  }
}
