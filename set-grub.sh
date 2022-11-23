#!/bin/bash

## back up grub cfg
cp /etc/default/grub /etc/default/grub.backup

## change /etc/default/grub
CMDLINE=$(cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX")
NEWLINE=$(echo "${CMDLINE::-1}" intel_iommu=on iommu=pt rd.driver.blacklist=nouveau\")

sed 's/'"${CMDLINE}"'/'"${NEWLINE}"'/g' /etc/default/grub.backup > /etc/default/grub

##
echo "Output of 'ls /boot/efi/EFI/'"
echo $(ls /boot/efi/EFI/)
echo "Please enter your boot OS"
read bootos

if [ ! -e /boot/efi/EFI/$bootos/grub.cfg ]; then
  echo "grub.cfg is empty, you may be use non-UEFI or syntax error"
  cp /etc/default/grub.backup /etc/default/grub
  rm -rf /etc/default/grub.backup
  exit 1
fi

cp /boot/efi/EFI/$bootos/grub.cfg /boot/efi/EFI/$bootos/grub.cfg.backup
grub2-mkconfig -o /boot/efi/EFI/$bootos/grub.cfg
