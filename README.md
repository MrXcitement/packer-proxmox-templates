# Packer Proxmox Templates
A project that uses Packer to creates Proxmox Template images

## Requirements
- the `packer` command line tool.

## Commands

### Install required plugins
The following command will install any required packer plugins.

`packer init .`

### Validate Packer Templates
The following command will validate all the packer template files.

`packer validate .`

Note: To limit the validation to a particular OS use the --only flag.

For example to validate just the Debian templates:
`packer validate --only '*.debian*' .`

### Build Proxmox Linux Templates
The following command will connect to a proxmox server and build all template images.

`packer build  .`

Note: To limit the build to a particular OS use the --only flag.

For example to build just the Debian templates:
`packer build --var-file=secrets.pkrvar.hcl --only '*.debian*' .`

## Notes
- When I run the build commands under Windows 11, I need to configure the `http_bind_address`, `http_port_min` and `http_port_max` settings. The packer command needs these to be able to connect back to the local machine that is running the web server to provide auto install / preseed files.

## References
- [packer command-line tool](https://www.packer.io/)
- [packer-plugin-proxmox](https://github.com/hashicorp/packer-plugin-proxmox)
