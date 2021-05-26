#!/bin/bash

echo "1 - Если у вас есть уже установленная система, то вы можете произвести установки, сохранив все данные из домашней папки пользователя. Выбрать раздел?"
echo "2 - Разметить диск"
read root

if [[ "$root" == "2" ]]; then
  fdisk -l
  echo "Выберите диск(например: /dev/sda): "
  read hard
  cfdisk $hard
fi

fdisk -l
echo "Выберите(например: /dev/sda1): "
read root_directory
echo "mount $root_directory /mnt"
if [[ "$root" == "2" ]]; then
  echo "Монтировать раздел для домашней папки?"
  echo "1 - Да"
  echo "2 - Нет"
  read home
  if [[ "$home" == "1" ]]; then
    echo "Выберите(например: /dev/sda1): "
    read home_directory
    echo "mkdir /mnt/home"
    echo "mount $home_directory /mnt/home"
  fi
fi
echo "Использовать раздел подкачки?"
echo "1 - Да"
echo "2 - Нет"
read swap
if [[ "$swap" == "1" ]]; then
  echo "Выберите(например: /dev/sda1): "
  read swap_directory
  echo "swapon $swap_directory"
fi
echo "Выберите ядро системы:"
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
sed '/%wheel ALL=(ALL) ALL/s/^#//g' -i  /mnt/etc/sudoers
if [[ "$root" == "1" ]]; then
  echo '
  echo "Введите свой регион(например: Europe): "
  read reg
  echo "Введите свой город(например: Moscow): "
  read city
  ln -sf /usr/share/zoneinfo/$reg/$city /etc/localtime
  hwclock --systohc --utc
  echo "Введите имя пользователя: "
  read pc_name
  echo "$pc_name" > /etc/hostname
  echo "127.0.1.1 localhost.localdomain $pc_name" > /etc/hosts
  systemctl enable networkmanager
  echo "Какая локаль вам нужна(например: ru_RU.UTF_8 UTF-8): "
  sed "/$locale/s/^#//g" -i  /mnt/etc/locale.gen
  sed "/en_US.UTF-8 UTF_8/s/^#//g" -i  /mnt/etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  usermod -aG wheel -s /bin/bash $user
  echo "Выберите оболочку системы:"
  echo "1 - KDE"
  echo "2 - GNOME"
  echo "3 - XFCE"
  echo "4 - "
  read de
  if [[ "$de" == "1" ]]; then
    pacman -Sy  xorg sddm plasma-meta dolphin konsole
    systemctl enable sddm
  elif [[ "$de" == "2" ]]; then
    pacman -Sy xorg
  elif [[ "$de" == "3" ]]; then
    pacman -Sy xorg xfce4 xfce4-goodies
    
  fi
  mkdir /boot/efi
  echo "Выберите EFI раздел(например: /dev/sda1):"
  read efi
  mount $efi /boot/efi
  pacman -S grub
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "Введите root пароль: "
  passwd
  exit
  umount -R /mnt
  reboot

  ' > setup_post.sh
elif [[ "$root" == "2" ]]; then
  echo '
  echo "Введите свой регион(например: Europe): "
  read reg
  echo "Введите свой город(например: Moscow): "
  read city
  ln -sf /usr/share/zoneinfo/$reg/$city /etc/localtime
  hwclock --systohc --utc
  echo "Введите имя пользователя: "
  read pc_name
  echo "$pc_name" > /etc/hostname
  echo "127.0.1.1 localhost.localdomain $pc_name" > /etc/hosts
  systemctl enable networkmanager
  echo "Какая локаль вам нужна(например: ru_RU.UTF_8): "
  nano /etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  echo "Введите имя пользователя: "
  read user
  useradd -m -g users -G wheel -s /bin/bash $user
  echo "Введите пароль: "
  passwd $user
  echo "Выберите оболочку системы:"
  echo "1 - KDE"
  echo "2 - GNOME"
  echo "3 - XFCE"
  echo "4 - "
  read de
  if [[ "$de" == "1" ]]; then
    pacman -Sy  xorg sddm plasma-meta dolphin konsole
    systemctl enable sddm
  elif [[ "$de" == "2" ]]; then
    pacman -Sy xorg
  elif [[ "$de" == "3" ]]; then
    pacman -Sy xorg xfce4 xfce4-goodies    
  fi
  mkdir /boot/efi
  echo "Выберите EFI раздел(например: /dev/sda1):"
  read efi
  mount $efi /boot/efi
  pacman -S grub
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "Введите root пароль: "
  passwd
  exit
  umount -R /mnt
  reboot
  ' > setup_post.sh
fi
mv setup_post.sh /mnt/setup.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
