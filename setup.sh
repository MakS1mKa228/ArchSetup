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
if [[ "$root" == "2" ]]; then
  echo "Format section?"
  echo "1 - Yes"
  echo "2 - No"
  read format_root
  if [[ "$format_root" == "1" ]]; then
    mkfs.ext4 $root_directory
  fi
  mount $root_directory /mnt
  echo "Mount partition for home folder?"
  echo "1 - Yes"
  echo "2 - No"
  read home
  if [[ "$home" == "1" ]]; then
    echo "Select (for example: /dev/sda1): "
    read home_directory
    echo "Format section?"
    echo "1 - Yes"
    echo "2 - No"
    read format_home
    if [[ "$format_root" == "1" ]]; then
      mkfs.ext4 $home_directory
    fi
    mkdir /mnt/home
    mount $home_directory /mnt/home
  fi
elif [[ "$root" == "1" ]]; then
  mount $root_directory /mnt
fi
echo "Use a swap partition?"
echo "1 - Yes"
echo "2 - No"
read swap
if [[ "$swap" == "1" ]]; then
  echo "Select(for example: /dev/sda1): "
  read swap_directory
  mkswap $swap_directory
  swapon $swap_directory
fi
mkdir /mnt/boot/efi
echo "Select an EFI partition (for example: /dev/sda1): "
read efi
echo "Format section?"
echo "1 - Yes"
echo "2 - No"
read format_efi
if [[ "$format_efi" == "1" ]]; then
  mkfs.fat -F32 $efi
fi
mount $efi /boot/efi

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
  pacstrap  /mnt base linux linux-firmware networkmanager wget git nano vim efibootmgr sudo sed
elif [[ "$kernel" == "2" ]]; then
  pacstrap  /mnt base linux-lts linux-firmware networkmanager wget git nano vim efibootmgr sudo sed
elif [[ "$kernel" == "3" ]]; then
  pacstrap  /mnt base linux-zen linux-firmware networkmanager wget git nano vim efibootmgr sudo sed
elif [[ "$kernel" == "4" ]]; then
  pacstrap  /mnt base linux-hardened linux-firmware networkmanager wget git nano vim efibootmgr sudo sed
fi
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
  read locale
  sed "/$locale/s/^#//g" -i  /etc/locale.gen
  sed "/en_US.UTF-8 UTF_8/s/^#//g" -i  /etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  usermod -aG wheel -s /bin/bash $user
  sed "/%wheel ALL=(ALL) ALL/s/^#//g" -i  /etc/sudoers
  username - $user
  echo "Select the system shell: "
  echo "1 - KDE"
  echo "2 - GNOME"
  echo "3 - XFCE"
  echo "4 - Cinnamon"
  echo "5 - Mate"
  echo "6 - Deepin"
  read de
  echo "Select video driver: "
  echo "1 - Nvdia"
  echo "2 - AMD"
  read driver
  if [[ "$driver" == "1" ]]; then
    if [[ "$de" == "1" ]]; then
      pacman -Sy plasma dolphin konsole nvidia-settings nvidia sddm xorg xorg-xinit
    elif [[ "$de" == "2" ]]; then
      pacman -Sy gnome gnome-extra nvidia-settings nvidia sddm xorg xorg-xinit
    elif [[ "$de" == "3" ]]; then
      pacman -Sy xfce4 xfce4-goodies nvidia-settings nvidia sddm xorg xorg-xinit
    elif [[ "$de" == "4" ]]; then
      pacman -Sy cinnamon nemo-fileroller nvidia-settings nvidia sddm xorg xorg-xinit
    elif [[ "$de" == "5" ]]; then
      pacman -Sy mate mate-extra nvidia-settings nvidia sddm xorg xorg-xinit
    elif [[ "$de" == "6" ]]; then
      pacman -Sy deepin deepin-extra nvidia-settings nvidia sddm xorg xorg-xinit
    fi
    systemctl enable sddm
  elif [[ "$driver" == "2" ]]; then
    if [[ "$de" == "1" ]]; then
      pacman -Sy plasma dolphin konsole mesa sddm xorg xorg-xinit
    elif [[ "$de" == "2" ]]; then
      pacman -Sy gnome gnome-extra mesa sddm xorg xorg-xinit
    elif [[ "$de" == "3" ]]; then
      pacman -Sy xfce4 xfce4-goodies mesa sddm xorg xorg-xinit
    elif [[ "$de" == "4" ]]; then
      pacman -Sy cinnamon nemo-fileroller mesa sddm xorg xorg-xinit
    elif [[ "$de" == "5" ]]; then
      pacman -Sy mate mate-extra mesa sddm xorg xorg-xinit
    elif [[ "$de" == "6" ]]; then
      pacman -Sy deepin deepin-extra mesa sddm xorg xorg-xinit
    fi
    systemctl enable sddm
  fi
  username - root
  pacman -S grub
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "Root password"
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
  read locale
  sed "/$locale/s/^#//g" -i  /etc/locale.gen
  sed "/en_US.UTF-8 UTF_8/s/^#//g" -i  /etc/locale.gen
  sed "/%wheel ALL=(ALL) ALL/s/^#//g" -i  /etc/sudoers
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  echo "Enter your username: "
  read user
  useradd -m -g users -G wheel -s /bin/bash $user
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
  echo "Select video driver: "
  echo "1 - Nvdia"
  echo "2 - AMD"
  read driver
  if [[ "$driver" == "1" ]]; then
    pacman -Sy nvidia-settings nvidia sddm xorg xorg-xinit
  elif [[ "$driver" == "2" ]]; then
      pacman -Sy mesa sddm xorg xorg-xinit
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
  pacman -S grub
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
  grub-mkconfig -o /boot/grub/grub.cfg
  passwd
  exit
  umount -R /mnt
  reboot
  ' > setup_post.sh
fi
mv setup_post.sh /mnt/setup.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
