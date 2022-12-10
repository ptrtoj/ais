#!/bin/sh

# You should modify these.
DISK="/dev/sda"
MYHOSTNAME="vm"
MYUSERNAME="jeon"

# Script
EXT4_PART="${DISK}3"

# Locale
sed -e 's/#en_US.UTF-8\ UTF-8/en_US.UTF-8 UTF-8/g' -i /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

# Timezone
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Hostname
echo ${MYHOSTNAME} > /etc/hostname

# Pacman/Makepkg
PACMAN_CONF_FILE="/etc/pacman.conf"
sed -e 's/#UseSyslog/UseSyslog/g'                           \
    -e 's/#Color/Color/g'                                   \
    -e 's/#VerbosePkgLists/VerbosePkgLists/g'               \
    -e 's/#ParallelDownloads = 5/ParallelDownloads = 10/g'  \
    -i ${PACMAN_CONF_FILE}

MAKEPKG_CONF_FILE="/etc/makepkg.conf"
sed -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j8"/g' -i ${MAKEPKG_CONF_FILE}

# Installing Arch Linux after arch-chroot.
echo "========================================================================="
echo "Setting root password"
passwd

# Add a user
useradd -m -g users -G wheel ${MYUSERNAME}
echo "========================================================================="
echo "Setting user password"
passwd ${MYUSERNAME}

# Bootloader
bootctl --path=/boot install

cat > /boot/loader/loader.conf << EOF
default arch
editor 1
timeout 1
EOF

# Microcode (with AMD CPU)
pacman -S --noconfirm amd-ucode

cat > /boot/loader/entries/arch.conf << EOF
title ArchLinux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
EOF
echo "options root=${EXT4_PART} rw" >> /boot/loader/entries/arch.conf

# If you want 'PARTUUID' in bootloader-arch.conf
#echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p3) rw">> /boot/loader/entries/arch.conf

systemctl enable NetworkManager.service

echo "========================================================================="
echo "Everything's installed..."
echo "Now you can..."
echo "========================================================================="
echo "#exit"
echo "#umount -lR /mnt"
echo "#reboot"
