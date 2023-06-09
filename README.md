# Packer Proxmox Templates
A project that uses Packer to creates Proxmox Template images

## Requirements
- the `packer` command line tool.

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

## Notes
- When I run the build commands under Windows 11, I end up with a template that has the wrong network interface and does not work correctly with cloud-init.

## References
- [packer command-line tool](https://www.packer.io/)
- [packer-plugin-proxmox](https://github.com/hashicorp/packer-plugin-proxmox)
