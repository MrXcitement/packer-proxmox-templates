source "proxmox-iso" "debian" {
    # Connection Configuration
    proxmox_url             = "${var.proxmox_api_url}"
    username                = "${var.proxmox_api_token_id}"
    token                   = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = "true"
    node                    = "sm1"

    # Location Configuration
    vm_name                 = "debian-11-template"
    vm_id                   = "9001"

    # Hardware Configuration
    sockets                 = "${var.vm_cpu_sockets}"
    cores                   = "${var.vm_cpu_cores}"
    memory                  = "${var.vm_mem_size}"
    cpu_type                = "${var.vm_cpu_type}"

    # Boot Configuration
    boot_command            = ["<esc><wait>", "install <wait>", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>", "debian-installer=en_GB.UTF-8 <wait>", "auto <wait>",
    "locale=en_GB.UTF-8 <wait>", "kbd-chooser/method=gb <wait>", "keyboard-configuration/xkb-keymap=gb <wait>", "netcfg/get_hostname=pkr-template-debian <wait>", "netcfg/get_domain=local.domain <wait>",
    "fb=false <wait>", "debconf/frontend=noninteractive <wait>",
    "console-setup/ask_detect=false <wait>", "console-keymaps-at/keymap=gb <wait>", "grub-installer/bootdev=/dev/sda <wait>", "<enter><wait>"]
    boot_wait               = "5s"

    # PACKER Autoinstall Settings
    # Http directory Configuration
    http_directory          = "debian/http"
    # (Optional) Bind IP Address and Port
    http_bind_address       = "192.168.1.142"  # set this to ip to where packer is run.
    http_port_min = 8802
    http_port_max = 8802

    # ISO Configuration
    iso_checksum            = "file:https://cdimage.debian.org/cdimage/release/11.7.0/amd64/iso-cd/SHA256SUMS"
    iso_file                = "proxmox:iso/debian-11.7.0-amd64-netinst.iso"
    #iso_url                 = "https://cdimage.debian.org/cdimage/release/10.9.0/amd64/iso-cd/debian-10.9.0-amd64-netinst.iso"
    #iso_storage_pool        = "iso-store"

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "proxmox"

    # VM Configuration
    os                      = "l26"
    vga {
        type                =  "std"
        memory              =  32
    }

    network_adapters {
        model               = "${var.vm_network_adapters_model}"
        bridge              = "${var.vm_network_adapters_bridge}"
        firewall            = true
    }

    disks {
        storage_pool      = "${var.vm_os_disk_storage_pool}"
        type              = "scsi"
        disk_size         = "${var.vm_os_disk_size}"
        cache_mode        = "none"
        format            = "qcow2"
    }

    template_name         = "debian-11-template"
    template_description  = "Debian 11 (Bullseye) Template"
    unmount_iso           = "true"
    qemu_agent            = "true"

    # Communicator Configuration
    # communicator           = "ssh"
    ssh_username           = "packer"
    ssh_password           = "packer"
    ssh_handshake_attempts = "20"
    ssh_timeout           = "1h30m"

}

build {
    # name = "ubuntu-server"
    sources = ["source.proxmox-iso.debian"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "#while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "#sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2.a
    provisioner "file" {
        # * The source is relative to the directory where the packer command is being ran from
        source = "./ubuntu/files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2.b
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Add additional provisioning scripts here
    # provisioner "shell" {
    #     inline = [
    #         "sudo apt-get install -y curl ca-certificates gnupg lsb-release",
    #         "sudo apt-get update -y",
    #         "sudo curl -sSL https://get.docker.com | bash" ,
    #         "sudo usermod -aG docker $(whoami)",
    #         "sudo apt-get install -y docker-compose"
    #         ]
    # }
}
