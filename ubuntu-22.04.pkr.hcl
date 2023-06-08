# Ubuntu 22.04 LTS (Jammy Jellyfish)
# Packer Template used to create Ubuntu Server on Proxmox

source "proxmox-iso" "ubuntu-server" {

    # * Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # ? (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # * VM General Settings
    # ! This needs to match the name of the proxmox node the template will be on
    node = "sm1"
    # ! VM ID needs to be unique
    vm_id = "8000"

    vm_name = "ubuntu-22.04-server-template"
    template_description = "Ubuntu Server 22.04.2 (Jammy Jellyfish) Image Template"

    # * VM OS Settings
    # ? This optional way specifys an iso file on proxmox
    iso_file = "proxmox:iso/ubuntu-22.04.2-live-server-amd64.iso"

    # ? This Will download the iso file every time and check it against the checksum
    # iso_url = "https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso"
    # iso_checksum = "5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
    # iso_storage_pool = "proxmox"
    # iso_download_pve = true
    unmount_iso = true

    # * VM System Settings
    # qemu_agent = true

    # * VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"
    disks {
        disk_size = "60G"
        format = "qcow2"
        storage_pool = "proxmox"
        type = "virtio"
    }

    # * VM CPU Settings
    cores = "4"

    # * VM Memory Settings
    memory = "4096"

    # * VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "proxmox"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "./ubuntu/http"
    # (Optional) Bind IP Address and Port
    http_bind_address = "192.168.1.142"  # set this to ip to where packer is run.
    # http_port_min = 8802
    # http_port_max = 8802

    ssh_username = "packer"

    # (Option 1) Add your Password here
    ssh_password = "packer"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    # ssh_private_key_file = "~/.ssh/id_ed25519"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    # name = "ubuntu-server"
    sources = ["source.proxmox-iso.ubuntu-server"]

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
