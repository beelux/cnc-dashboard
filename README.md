# Command and Control
These scripts automate the [Command and Control](https://wiki.c3l.lu/doku.php?id=projects:hardware:command_and_control) SBC installation as much as possible.

Note that git submodules **must** be initalized, they contain crucial information such as the [SSH host keys and the public key of autom8](https://projects.c3l.lu/ChaosStuff/cnc-host-keys). Special access is needed.

## How to use
Flash the image on the eMMC using the flashEMMC.sh script (see section). Then use ansible.sh to install and configure the installation.

### Structure of submodule
```
files
├── autom8_public_key
├── mcr-alpha
│   └── ssh_host_*
├── mcr-beta
│   └── ssh_host_*
├── mcr-delta
│   └── ssh_host_*
└── mcr-gamma
    └── ssh_host_*
```

## Requirements
- Ansible (+ requirements.txt)
- expect
- sshpass
- OpenSSH tools (ssh-keygen, ssh-copy-id)

## Scripts
There are various scripts, some of which are supposed to be used directly, while others are used by Ansible itself.

### flashEMMC.sh
Usage: 
`sudo ./flashEMMC.sh [block device name, e.g. sdb]`

This script automates the installation of the ArchLinuxARM ODROID C2 image. (as shown on the [ALARM installation page](https://archlinuxarm.org/platforms/armv8/amlogic/odroid-c2#installation))

It shows the user information about the block device they indicated, asking if it is the right device. If it is, all mounts related to this block device are unmounted, a couple of blocks at the start are zero-ed out, the partition table is created, the single partition's FS is created, the ALARM image downloaded, hash verified, the parition is mounted, the tarball extracted, then the bootloader is installed. Finally, everything is `sync`-ed, and the directory unmounted.

### ansible.sh
Usage: 
`sudo ./ansible.sh [playbook file, if none, site.yml]`

It simply verifies that the ansible requirements.txt are met and runs through the specific playbook.
