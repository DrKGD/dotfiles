# Deatharte .dotfiles

# WIP 
- [ ] Tutorial 
	- [x] Prepare Arch installation
	- [x] Earth (Orbit/Moon)
	- [ ] No User Interaction, Full Installation Script
	- [ ] Finalize setup with a single script
		- [ ] Paru
		- [ ] Drivers	and peripherals
			- [ ] GPU and Monitors
				- [x] Intel for LAPTOP-DRKGD, x11
				- [ ] Nvidia for DESKTOP-DRKGD, x11
					- [ ] xrand the monitors
			- [ ] Logitech
			- [ ] Bluetooth
			- [ ] Home Printer
			- [ ] Keyboard and Mouse
				- [ ] Remap keys
					- [ ] CAPS to L_CTRL
					- [ ] L_CTRL to R_CTRL
					- [ ] R_CTRL to VK
					
				- [ ]
		- [x] Applications
			- [x] Editor (nvim)
			- [x] Browser (firefox)
			- [x] PDFViewer (sioyek)
			- [x] Telegram, Whatsapp
			- [x] VLC
		- [ ] Desktop Environment
			- [ ] Configure fonts 
			- [ ] Configure icons
			- [ ] Configure theme(s)
			- [x] Greeter (sddm) 
				- [ ] Configure theme(s)
			- [x] DE itself (i3)
			- [x] Compositor (picom)

# Tutorial(s)
## Format USB-Drive
```bash
# Insert USB and Find disk with df utility
df

# un-mount the drive
sudo umount /dev/the-drive

# format drive
sudo mkfs.vfat -F 32 -n "label" /dev/the-drive
sudo mkfs.ntfs /dev/the-drive
sudo mkfs.exfat /dev/the-drive

# check operation result (has to return something along the lines of 1/N clusters)
sudo fsck /dev/the-drive
```

## Prepare Arch Live-CD
Get last Arch Linux live-cd ISO (for convenience ofc). Using a virgin flash-drive, run the following
```bash
dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress && sync
```

## First steps in the installation process
1. Setup keyboard layout (not required if you are going to use qwerty en-US)
```bash
# list keymaps
ls /usr/share/kbd/keymaps/**/*.map.gz

# load keymaps (e.g. de-latin1.map.gz)
loadkeys de-latin1
```

2. Verify bootmode (UEFI)
```bash
ls /sys/firmware/efi/efivars
```

3. Retrieve WiFi connection
```bash
iwctl
iwd# device list

# wlan0 is the wireless card name
iwd# station wlan0 scan
iwd# station wlan0 get-networks

# connect (password prompt)
iwd# station wlan0 connect "NetworkName"
```

4. Partition the disk

List the disk(s): hdd(s) are listed as rotational disks (flag: 1), ssd are not (flag: 0).
```bash
# Show disk information
lsblk -d -o name,rota

# Show current Partition(s)
lsblk
# or 
fdisk -l

# Remove partitions on the disk, if any
fdisk
fdisk# d

# Add partitions
# efi		~1gb if plenty
# swap	at least RAM_SIZE+sqrt(RAM_SIZE), also not required if system has a lot of ram (imho)
# leave everything else to data partition
fdisk# n

# Change partition types
# efi		has type 1
# swap	has type 19
fdisk# t

# Write the disk
fdisk# w 
```

5. Format the partitions 

```bash
# efi partition
mkfs.fat -F 32 /dev/the-disk-p1

# swap 
mkswap /dev/the-disk-p2
swapon /dev/the-disk-p2

# data (tbh pick a format, don't really care which one)
mkfs.ext4 /dev/sda3
```

6. Install Arch Linux
```bash
# mount data partition
mount /dev/sda3 /mnt
pacstrap /mnt base linux linux-firmware

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

```

7. Wrap up installation 
```bash
# mount new directory 
arch-chroot /mnt

# run the script
./ArchLinux.install-script.sh

# unmount
umount -R /mnt
```

8. Finalizing installation
```bash
# Connect to the wifi
sudo nmcli device wifi list
sudo nmcli device wifi connect <SSID> password <PWD>

# Install Paru 
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git /tmp/paru/
cd /tmp/paru/
makepkg -si

```

9. Install DE
```bash
# Install Drivers 
# Laptop (xorg) (intel)
sudo pacman -S mesa xorg-server

# Install neovim (editor), wezterm (terminal emulator), sioyek (pdf)
yes | paru -S --needed --noconfirm neovim-nightly-bin wezterm-nightly-bin sioyek

# Install SDDM, i3, dmenu, firefox, picom
# https://github.com/stuomas/delicious-sddm-theme
yes | sudo pacman -S --needed --noconfirm sddm firefox dmenu picom

# TODO: Missing, file manager
```



# Complementary configuration (requires attention)
## Screen setup
Run `xrandr` to read which monitors are available and which are their possible settings.

It is preferable to add the configuration in a way that 
it is actually changed as soon as possible,
like directly onto the display manager (such as SDDM).

When unsure, just test monitor-by-monitor until satisfied.

Current configuration for DESKTOP-DRKGD, with triple monitor setup (plus the television) is located at
/usr/share/sddm/scripts/Xsetup
```bash
#!/bin/sh/

xrandr --output DVI-I-1 --rate 144.00 --mode 1920x1080 --primary
xrandr --output DP-1 --rate 60.00 --mode 1920x1080 --left-of DVI-I-1
xrandr --output DVI-D-0 --rate 60.00 --mode 1920x1080 --right-of DVI-I-1
xrandr --output HDMI-0 --rate 60.00 --mode 1920x1080 --right-of DVI-I-1
```

Finally, let the configuration take effect thus configure `/etc/sddm.conf`
```bash
[XDisplay]
DisplayCommand=/usr/share/sddm/scripts/Xsetup
```

## Background
tbh I had absolutely no idea which software to use. In the end I opted for `xwallpaper`.
```bash
xwallpaper --no-randr --tile ~/Pictures/Desktop_5_d.png 
```

## Keyboard event remapping 
Using this [https://askubuntu.com/questions/742946/how-to-find-the-hwdb-header-of-a-general-input-device](guide).
1. Find device vendor id using lsusb (they are written as vendor:product), e.g. `1ea7`
1. Run `find /sys -name *modalias | xargs grep -i $vendor`, replace `$vendor` with previous output. Look up for shorter output. Its modalias should _probably_ start with `input:b` (not sure).
e.g. `/sys/devices/pci0000:00/0000:00:01.2/0000:20:00.0/0000:21:08.0/0000:2a:00.1/usb1/1-2/1-2.1/1-2.1:1.1/0003:1EA7:0002.000E/input/input45/modalias:input:b0003v1EA7p0002e0110-e0,3,kra28,mlsfw`
1. Look at `MSG_SCAN` field using the `evtest` command (requires sudo). For example, tab is `7002b`.
1. Push a new file `/etc/udev/hwdb.d/90-custom-keyboard.hwdb` which has the following content (n.d.r. copy the _b-string_ until `e`)
```bash
evdev:input:b0003v1EA7p0002*
 KEYBOARD_KEY_7002b=leftctrl
```

### TES68
```bash
evdev:input:b0003v1EA7p0002*
 KEYBOARD_KEY_70039=leftctrl
 KEYBOARD_KEY_700e4=kp0
 KEYBOARD_KEY_700e0=rightctrl
```

## mpd (music player)
Configure as a user systemctl process.
```
sudo systemctl --user enable mpd
```

## fonts
Following this guide:
[https://wiki.manjaro.org/index.php/Improve_Font_Rendering](Improve Font Rendering)

Also, please install Scientifica TTF from arch repo(s) `scientifica-bdf`

## nvidia multi-screen for xorg fix
Configure the nvidia-settings using this guide.
[https://www.reddit.com/r/linux_gaming/comments/jupdco/psa_picomcompton_users_with_a_bonus_nvidia_trick/](nvidia-settings)

From the OpenGL Settings, disable `Allow Flipping`.
On `X Server Display Configuration`, `Advanced`, apply `Force Full Composition Pipeline` on lower refresh rate monitors.


