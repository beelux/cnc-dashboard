#!/usr/bin/env bash
DEV=$1
IMAGE_NAME=ArchLinuxARM-odroid-c2-latest.tar.gz
# Fast mirror, but I'm not sure we can trust it...
DOWNLOAD_LINK=https://mirrors.dotsrc.org/archlinuxarm/os/
HASH_LINK=https://de3.mirror.archlinuxarm.org/os/


checkRoot() {
	[[ "$EUID" -eq 0 ]] || { echo "Run script (as root) or (with sudo)"; exit 1; }
}

diskInfo() {
	[[ -e /dev/$DEV ]] || { echo "ERROR: Drive doesn't exist" && exit 1; }
	fdisk -l /dev/$DEV
	echo
}

verifyRightDrive() {
	sleep 3
	read -n 1 -r -p "Is this the right drive? [y/N] " response
	if [[ "$response" =~ ^([yY])$ ]]
	then
		return 0
	else
		echo
		exit 1
	fi
}

umountInitially() {
	BLKDEVS=$(find /dev/ -name ${DEV}*)
	for LINE in $BLKDEVS; do
		sudo umount $LINE
	done
}

zeroBeginning() {
	dd if=/dev/zero of=/dev/$DEV bs=1M count=8
}

partitionEMMC() {
fdisk -W always /dev/$DEV << EOF
o
n
p
1



w
EOF
}

createEXT4fs() {
	mkfs.ext4 -O ^metadata_csum,^64bit /dev/${DEV}1
}

cdToScript() {
	TMP=$(dirname "$0")
	cd $TMP
	mkdir flashEMMC
	cd flashEMMC
}

unmountFS() {
	umount root
}

panic() {
	cdToScript
	unmountFS
	exit 1
}

downloadImage() {
	rm ${IMAGE_NAME}
	wget ${DOWNLOAD_LINK}${IMAGE_NAME}
	wget ${HASH_LINK}${IMAGE_NAME}.md5
	md5sum -c ${IMAGE_NAME}.md5 || { echo "Hash of image is incorrect"; panic; }
}

extractImage() {
	bsdtar -xpf ArchLinuxARM-odroid-c2-latest.tar.gz -C root
}

mountFS() {
	mkdir root
	mount /dev/${DEV}1 root
	[ -e ${IMAGE_NAME}.md5 ] && md5sum -c ${IMAGE_NAME}.md5 || downloadImage && extractImage
}

flashBootloader() {
	cd root/boot
	./sd_fusing.sh /dev/${DEV}
	cd ../..
}


main() {
	checkRoot
	diskInfo
	verifyRightDrive
	umountInitially
	zeroBeginning
	partitionEMMC
	createEXT4fs
	cdToScript
	mountFS
	flashBootloader
	unmountFS
}

main
