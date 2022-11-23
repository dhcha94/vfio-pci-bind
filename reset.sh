#!/bin/bash

rm -rf /etc/udev/rules.d/25-vfio-pci-bind.rules
rm -rf /lib/udev/vfio-pci-bind.sh
rm -rf /etc/modprobe.d/vfio.conf
rm -rf /etc/modules-load.d/vfio-pci.conf

cp /etc/default/grub.backup /etc/default/grub
rm -rf /etc/default/grub.backup

backup=$(find /boot -name "*backup")

cp $backup ${backup::-7}
rm -rf $backup

echo "Reset completed"
