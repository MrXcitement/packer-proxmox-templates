# Proxmox Packer Linux
A Packer project used to creates Proxmox Template Linux boxes

## Commands
### Install required plugins
packer init ubuntu-22.04.pkr.hcl

### Validate Packer Template
packer validate --var-file=proxmox_variables.pkr.hcl ubuntu-22.04.pkr.hcl

### Build Proxmox Linux box
packer build --var-file=proxmox_variables.pkr.hcl ubuntu-22.04.pkr.hcl

For cloud init to work the `http` folder **must** have both `user-data` and `meta-data` files.

## References
- [packer-plugin-proxmox](https://github.com/hashicorp/packer-plugin-proxmox)
