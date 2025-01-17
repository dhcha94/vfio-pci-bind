# vfio-pci-bind

This script takes one or two parameters in any order:

- `Vendor:Device` i.e. `vvvv:dddd`
- `Domain:Bus:Device.Function` i.e. `dddd:vv:dd.f`

and then:

1. If both `Vendor:Device` and `Domain:Bus:Device.Function` were provided, validate that the requested `Vendor:Device` exists at `Domain:Bus:Device.Function`

   If only `Vendor:Device` was provided, determine the current `Domain:Bus:Device.Function` for that device.

   If only `Domain:Bus:Device.Function` was provided, use it.

2. Unbinds all devices that are in the same iommu group as the supplied device from their current driver (except PCIe bridges).

3. Binds to vfio-pci:

   1. The supplied device.
   2. All devices that are in the same iommu group.

4. Transfers ownership of the respective iommu group inside /dev/vfio to \$SUDO_USER

Suggestions:

- If you have a single piece of hardware with a given `Vendor:Device`, you can call the script like this:

  `vfio-pci-bind.sh Vendor:Device`

  The script will target that device regardless of how the PCI address might change due to the addition or removal of other hardware.

- If you have multiple pieces of hardware with the same `Vendor:Device` code, you need to pass the PCI address as well:

  `vfio-pci-bind.sh Vendor:Device Domain:Bus:Device.Function`

  This will ensure the correct instance of the hardware is bound to vfio-pci.

  Note: If the PCI address for this device changes as a result of adding or removing hardware, you will need to update the PCI address in this call.

- For backwards compatibility you can also specify just the PCI address:

  `vfio-pci-bind.sh Domain:Bus:Device.Function`

  Note: If you add or remove hardware, the device associated with that PCI address can change resulting in the wrong device being bound to vfio-pci. Consider passing the `Vendor:Device` as well.

**Script must be executed via sudo!**

## Automatically binding devices on boot

Devices can be automatically bound to `vfio-pci` on boot using the supplied `25-vfio-pci-bind.rules` udev rules file.
1. Copy `vfio-pci-bind.sh` to `/lib/udev/` and ensure it is marked executable.
2. Copy `25-vfio-pci-bind.rules` to `/etc/udev/rules.d/`
3. Edit `/etc/udev/rules.d/25-vfio-pci-bind.rules` and add PCI device matching rules following the examples in the file.
4. Reboot.

## set-bind.sh

This script will discover NVIDIA product (VendorID : 10de) and create automatically binding script

Test on Centos 7, Rocky 8.6

1. Copy set-bind.sh, vfio-pci-bind.sh, 25-vfio-pci-bind.rules.empty in same directory
2. Make set-bind.sh executable and run.

## set-grub.sh

Set grub.cfg automatically when you use UEFI boot OS, just type your os

**Before reboot please check your grub file again**

`cat /etc/default/grub`

## Clean up

Run reset.sh

## License

See supplied LICENSE file.
