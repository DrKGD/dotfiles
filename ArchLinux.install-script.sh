#!/usr/bin/sh

## Exit on first error
set -euxo pipefail

## Show disk(s)
lslsk
echo "Please enter efi boot partition: "
read READ_EFIBOOT
## Once arch-chroot'ed to /mnt
echo "Please enter hostname for the selected computer: "
read READ_HOSTNAME

echo "Please enter the user"
read READ_USERNAME 

echo "'$READ_EFIBOOT' is the efi boot partition (grub)"
echo "<$READ_HOSTNAME> selected as the new hostname!" 
echo "<$READ_USERNAME> will be created!"

echo "ArchLinux Installation will now continue"
for i in $(seq 1 10); do 
	echo -ne "Time before running the script: $((10 - i))s\033[0K\r"
	sleep 1s
done
echo


## Set zone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

## Set hwclock
hwclock --systohc

## Update locale.gen with both italian and english locales
# n.b. no need to panic, a backup of the original file is located at
# /var/cache/pacman/pkg/glibc-*.tar.*
cat <<: > /etc/locale.gen
# Custom locale(s)
en_US.UTF-8 UTF-8
it_IT.UTF-8 UTF-8
:
locale-gen

# Setup Locale(s)
cat <<: > /etc/locale.conf
LANG="en_US.UTF-8"
LC_MEASUREMENTS="it_IT.UTF-8"
LC_TIME="it_IT.UTF-8"
LC_PAPER="it_IT.UTF-8"
:

# Reload locale settings
unset LANG
source /etc/profile.d/locale.sh

## Set HOSTNAME 
echo "$READ_HOSTNAME" > /etc/hostname
cat <<: > /etc/hosts
127.0.0.1	localhost
::1				localhost
127.0.1.1	$READ_HOSTNAME.localdomain	$READ_HOSTNAME
:

## User(s)
# Set root password
echo "Please enter root user new password:"
passwd

# Add new user, ask for his password and add him to the groups
echo "Creating user <$READ_USERNAME>"
useradd -m $READ_USERNAME
passwd $READ_USERNAME
usermod -aG wheel,audio,video,storage

# enable use of sudo to users in the wheel group
yes | pacman -S sudo
sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //g' /etc/sudoers

## Install grub
yes | pacman -S grub efibootmgr dosfstools os-prober mtools
mkdir /boot/EFI
mount $READ_EFIBOOT /boot/EF		I
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

## Install non-graphical packages 
# Install reflector
yes | pacman --noconfirm -S reflector
cat <<: > /etc/xdg/reflector/reflector.conf
--save /etc/pacman.d/mirrorlist
--country Italy,Switzerland,France,Germany
--sort rate
--protocol https
--latest 10
:

# Enable auto-update service and update mirrors
systemctl enable reflector.service
reflector --save /etc/pacman.d/mirrorlist --country Italy,Switzerland,France,Germany \
	--protocol https --latest 10

# Install most
yes | pacman --noconfirm --needed -S networkmanager vim nvim git zsh vlc \
	gcc base-devel texlive-most texlive-core python python-pip nodejs make \
	xclip ripgrep fd

# Enable NetworkManager
systemctl enable NetworkManager


# Install Paru 
pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git /tmp/paru/
cd paru
makepkg -si




