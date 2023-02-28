#!/bin/sh

# Preparing for arch-chroot
# You must prepare disk format
# before running below.
#
# Also, you must check each variables
# that are mounted along the script.
#
# That means you should have already
# done below commands.
# #wipefs --all $DISK
# #parted $DISK mklabel gpt
# #cfdisk

# You should modify this.
#DISK="/dev/sda"
DISK="/dev/nvme0n1"

# Script
# If you use disk like '/dev/sda',
# you should fix below as '${DISK}/1'
VFAT_PART="${DISK}p1"
SWAP_PART="${DISK}p2"
EXT4_PART="${DISK}p3"

mkfs.vfat -F 32 $VFAT_PART
mkfs.ext4 -j $EXT4_PART
mkswap $SWAP_PART
swapon $SWAP_PART

mount $EXT4_PART /mnt
mkdir -p /mnt/boot
mount $VFAT_PART /mnt/boot

timedatectl set-ntp true
sleep 3s
hwclock --systohc --utc

reflector -c KR > /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel linux linux-firmware networkmanager man-db man-pages
genfstab -U /mnt >> /mnt/etc/fstab

curl -L -o /mnt/pro-chroot.sh https://github.com/ptrtoj/ais/raw/master/pro-chroot.sh

echo "========================================================================="
echo "Everything's prepared to be chrooted..."
echo "Now you can..."
echo "========================================================================="
echo "#arch-chroot /mnt"
echo "And run ./pro-chroot.sh"
