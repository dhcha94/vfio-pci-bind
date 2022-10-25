#!/bin/bash

CMD1=$(command -v lspci 2>/dev/null)
CMD2=$(command -v modprobe 2>/dev/null)
CMD3=$(command -v setpci 2>/dev/null)
bind="vfio-pci-bind.sh"
rule="25-vfio-pci-bind.rules.empty"

count=0

## command check
for var in $CMD1 $CMD2 $CMD3
do
  count=$(($count+1))
done

if [ $count != 3 ];
  then echo "please install pciutils or modprobe first"
  exit 1
fi

## script check
if [ ! -e $bind ];
  then echo "need vfio-pci-bind.sh in same directory"
  exit 1
elif [ ! -e $rule ];
  then echo "need 25-vfio-pci-bind.rules.empty in same directory"
  exit 1
fi

## set productID
COUNT=$(lspci -n -d 10de: 2>/dev/null | wc -l)
if [[ $COUNT -eq 0 ]]; then
  echo "Error: NVIDIA product not found" 1>&2
  exit 1
fi

list=$(lspci -n -d 10de: | cut -d ":" -f4)

unset product
for var in ${list}
do
  product=$product"ATTR{vendor}==\"0x10de\", ATTR{device}==\"0x$var\", TAG=\"vfio-pci-bind\"\n"
done

sed 's/#changehere/'"${product}"'/g' 25-vfio-pci-bind.rules.empty > 25-vfio-pci-bind.rules

## chmod
chmod 744 vfio-pci-bind.sh

## lib copy
cp $CMD1 /lib/udev/lspci
cp $CMD2 /lib/udev/modprobe
cp $CMD3 /lib/udev/setpci

## copy managed files
mv 25-vfio-pci-bind.rules /etc/udev/rules.d/25-vfio-pci-bind.rules
cp vfio-pci-bind.sh /lib/udev/vfio-pci-bind.sh
echo "vfio-pci" > /etc/modules-load.d/vfio-pci.conf

unset vddv
vddv=$(lspci -n -d 10de: | cut -d " " -f3)
vddv=$(echo -e ${vddv} | tr " " ",")
echo "options vfio-pci ids=$vddv"  > /etc/modprobe.d/vfio.conf

echo "patch completed, please reboot your machine"

