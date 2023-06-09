# Packer Proxmox Templates
A Packer project used to creates Proxmox Template boxes

## Commands

### Install required plugins
The following command will install any required packer plugins.

`packer init .`

### Validate Packer Templates
The following command will validate the packer template files.

`packer validate --var-file=secrets.pkrvar.hcl .`

Note: To limit the validation to a particular OS use the --only flag.

For example to validate just the debian templates:
`packer validate --var-file=secrets.pkrvar.hcl --only *.debian`

### Build Proxmox Linux Templates
The following command will connect to a proxmox server and build a template image.

`packer build --var-file=secrets.pkrvar.hcl .`

Note: To limit the validation to a particular OS use the --only flag.

For example to build just the debian templates:
`packer build --var-file=secrets.pkrvar.hcl --only *.debian`

## References
- [packer-plugin-proxmox](https://github.com/hashicorp/packer-plugin-proxmox)
