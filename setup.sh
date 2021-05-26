#!/bin/bash

echo "1 - If you have an already installed system, then you can make settings, saving all data from the user's home folder. Select a section?"
echo "2 - Partition disk"
read root

if [[ "$root" == "2" ]]; then
  fdisk -l
  echo "Select the drive (for example: /dev/sda): "
  read hard
  cfdisk $hard
fi

fdisk -l
echo "Select (for example: /dev/sda1): "
read root_directory
echo "mount $root_directory /mnt"
if [[ "$root" == "2" ]]; then
  echo "Mount partition for home folder?"
  echo "1 - Yes"
  echo "2 - No"
  read home
  if [[ "$home" == "1" ]]; then
    echo "Select (for example: /dev/sda1): "
    read home_directory
    mkdir /mnt/home
    mount $home_directory /mnt/home
  fi
fi
echo "Use a swap partition?"
echo "1 - Yes"
echo "2 - No"
read swap
if [[ "$swap" == "1" ]]; then
  echo "Выберите(например: /dev/sda1): "
  read swap_directory
  swapon $swap_directory
fi
echo "Select the system kernel: "
echo "1 - linux"
echo "2 - linux_lts"
echo "3 - linux_zen"
echo "4 - linux_hardened"
read kernel
if [[ "$root" == "1" ]]; then
  ls /mnt| grep -v /mnt/home | xargs rm -rfv
fi
if [[ "$kernel" == "1" ]]; then
  pacstrap -i /mnt base linux linux-firmware NetworkManager wget git nano vim efibootmgr sudo
elif [[ "$kernel" == "2" ]]; then
  pacstrap -i /mnt base linux-lts linux-firmware NetworkManager wget git nano vim efibootmgr sudo
elif [[ "$kernel" == "3" ]]; then
  pacstrap -i /mnt base linux-zen linux-firmware NetworkManager wget git nano vim efibootmgr sudo
elif [[ "$kernel" == "4" ]]; then
  pacstrap -i /mnt base linux-hardened linux-firmware NetworkManager wget git nano vim efibootmgr sudo
fi
pacman -S sed
sed '/%wheel ALL=(ALL) ALL/s/^#//g' -i  /mnt/etc/sudoers
if [[ "$root" == "1" ]]; then
  echo '
  echo "Enter your region (for example: Europe): "
  read reg
  echo "Enter your city (for example: Moscow): "
  read city
  ln -sf /usr/share/zoneinfo/$reg/$city /etc/localtime
  hwclock --systohc --utc
  echo "Enter the computer name: "
  read pc_name
  echo "$pc_name" > /etc/hostname
  echo "127.0.1.1 localhost.localdomain $pc_name" > /etc/hosts
  systemctl enable networkmanager
  echo "What locale do you need (for example: ru_RU.UTF_8 UTF-8): "
  sed "/$locale/s/^#//g" -i  /mnt/etc/locale.gen
  sed "/en_US.UTF-8 UTF_8/s/^#//g" -i  /mnt/etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  usermod -aG wheel -s /bin/bash $user
  username - $user
  echo "Select the system shell: "
  echo "1 - KDE"
  echo "2 - GNOME"
  echo "3 - XFCE"
  echo "4 - Cinnamon"
  echo "5 - Mate"
  echo "6 - Deepin"
  read de
  pacman -Sy sddm xorg xorg-xinit
  echo "Select video driver: "
  echo "1 - Nvdia"
  echo "2 - AMD"
  read driver
  if [[ "$driver" == "1" ]]; then
    pacman -Sy nvidia-settings nvidia
  elif [[ "$driver" == "2" ]]; then
      pacman -Sy mesa
  fi
  systemctl enable sddm
  if [[ "$de" == "1" ]]; then
    pacman -Sy plasma dolphin konsole
  elif [[ "$de" == "2" ]]; then
    pacman -Sy gnome gnome-extra
  elif [[ "$de" == "3" ]]; then
    pacman -Sy xfce4 xfce4-goodies
  elif [[ "$de" == "4" ]]; then
    pacman -Sy cinnamon nemo-fileroller
  elif [[ "$de" == "5" ]]; then
    pacman -Sy mate mate-extra
  elif [[ "$de" == "6" ]]; then
    pacman -Sy deepin deepin-extra
  fi
  username - root
  mkdir /boot/efi
  echo "Select an EFI partition (for example: /dev/sda1): "
  read efi
  mount $efi /boot/efi
  pacman -S grub
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "Enter root password: "
  passwd
  exit
  umount -R /mnt
  reboot

  ' > setup_post.sh
elif [[ "$root" == "2" ]]; then
  echo '
  echo "Enter your region (for example: Europe): "
  read reg
  echo "Enter your city (for example: Moscow): "
  read city
  ln -sf /usr/share/zoneinfo/$reg/$city /etc/localtime
  hwclock --systohc --utc
  echo "Enter the computer name: "
  read pc_name
  echo "$pc_name" > /etc/hostname
  echo "127.0.1.1 localhost.localdomain $pc_name" > /etc/hosts
  systemctl enable networkmanager
  echo "What locale do you need (for example: ru_RU.UTF_8 UTF-8): "
  nano /etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  echo "Enter your username: "
  read user
  useradd -m -g users -G wheel -s /bin/bash $user
  echo "Enter password: "
  passwd $user
  username - $user
  echo "Select the system shell: "
  echo "1 - KDE"
  echo "2 - GNOME"
  echo "3 - XFCE"
  echo "4 - Cinnamon"
  echo "5 - Mate"
  echo "6 - Deepin"
  read de
  pacman -Sy sddm xorg xorg-xinit
  echo "Select video driver: "
  echo "1 - Nvdia"
  echo "2 - AMD"
  read driver
  if [[ "$driver" == "1" ]]; then
    pacman -Sy nvidia-settings nvidia
  elif [[ "$driver" == "2" ]]; then
      pacman -Sy mesa
  fi
  systemctl enable sddm
  if [[ "$de" == "1" ]]; then
    pacman -Sy plasma dolphin konsole
  elif [[ "$de" == "2" ]]; then
    pacman -Sy gnome gnome-extra
  elif [[ "$de" == "3" ]]; then
    pacman -Sy xfce4 xfce4-goodies
  elif [[ "$de" == "4" ]]; then
    pacman -Sy cinnamon nemo-fileroller
  elif [[ "$de" == "5" ]]; then
    pacman -Sy mate mate-extra
  elif [[ "$de" == "6" ]]; then
    pacman -Sy deepin deepin-extra
  fi
  username - root
  mkdir /boot/efi
  echo "Select an EFI partition (for example: /dev/sda1): "
  read efi
  mount $efi /boot/efi
  pacman -S grub
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "Enter root password: "
  passwd
  exit
  umount -R /mnt
  reboot
  ' > setup_post.sh
fi
mv setup_post.sh /mnt/setup.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
