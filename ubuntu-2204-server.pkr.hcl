# Ubuntu 22.04 Server LTS (Jammy Jellyfish)
# Packer Template used to create Ubuntu Server on Proxmox
source "proxmox-iso" "ubuntu-2204-server" {

    # Proxmox Connection
    proxmox_url              = "${var.proxmox_api_url}"
    username                 = "${var.proxmox_api_token_id}"
    token                    = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = true

    # Proxmox Node
    node                     = "sm1"

    # VM ID and Names
    vm_id                    = "9010"
    vm_name                  = "ubuntu-22.04-server-template"
    template_name            = "ubuntu-22.04-server-template"
    template_description     = "Ubuntu 22.04.2 Server LTS (Jammy Jellyfish) Template"

    # Packer Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot                     = "c"
    boot_wait                = "5s"

    # Packer Autoinstall Web Server
    http_directory           = "./ubuntu/http"
    # (Optional) Bind IP Address and Port
    # Note: On Windows 11 I needed to set the http_bind_address to the local workstation
    # and uncomment the http_port_min and http_port_max setting for the build to succeed.
    # http_bind_address        = "192.168.1.142"  # set this to ip to where packer is run.
    # http_port_min            = 8802
    # http_port_max            = 8802

    # ISO Configuration
    iso_file                 = "proxmox:iso/ubuntu-22.04.2-live-server-amd64.iso"
    # (Optional) This will download the iso file every time and check it against the checksum
    # iso_url                  = "https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso"
    # iso_checksum             = "5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
    # iso_storage_pool         = "proxmox"
    # iso_download_pve         = true
    unmount_iso              = true

    # VM Cloud-Init Settings
    cloud_init               = true
    cloud_init_storage_pool  = "proxmox"

    # VM Configuration
    sockets                  = "${var.vm_cpu_sockets}"
    cores                    = "${var.vm_cpu_cores}"
    memory                   = "${var.vm_mem_size}"
    cpu_type                 = "${var.vm_cpu_type}"

    os                       = "l26"
    vga {
        type                 =  "std"
        memory               =  32
    }

    network_adapters {
        model                = "${var.vm_network_adapters_model}"
        bridge               = "${var.vm_network_adapters_bridge}"
        firewall             = true
    }

    scsi_controller          = "virtio-scsi-pci"
    disks {
        storage_pool         = "${var.vm_os_disk_storage_pool}"
        type                 = "virtio"
        disk_size            = "${var.vm_os_disk_size}"
        cache_mode           = "none"
        format               = "qcow2"
    }
    qemu_agent            = "true"

    # Communicator Configuration
    # communicator             = "ssh"
    ssh_username             = "packer"
    ssh_password             = "packer"
    # ssh_private_key_file     = "~/.ssh/id_ed25519"
    ssh_handshake_attempts   = "20"
    ssh_timeout              = "30m"
}

# Build Definition to create the VM Template
build {

    #name                     = "ubuntu-2204-server"
    sources                  = ["source.proxmox-iso.ubuntu-2204-server"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2.a
    provisioner "file" {
        # * The source is relative to the directory where the packer command is being ran from
        source      = "./ubuntu/files/99-pve.cfg"
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
