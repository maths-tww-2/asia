#!/bin/bash

# Made by: Maths and itsgerliz
# This project and its respectives files are protected by the GNU General Public License 3 (read LICENSE)

echo "You are supposed to run this inside arch-chroot"
echo -n "Let's install grub packages (press enter to continue)"
read
pacman -S grub
echo ""
while true; do
	echo -n "Do you use UEFI or BIOS? [UEFI/BIOS]: "
	read bootype
	if [ "$bootype" == "BIOS" ]; then
		break
	elif [ "$bootype" == "UEFI" ]; then
		pacman -S efibootmgr
		break
	else
		echo "Not a valid option."
	fi
done
echo ""

if [ "$bootype" == "UEFI" ]; then
	echo -n "Are you installing arch on a removable device? [yes/no]:"
	read removable
	if [ "$removable" == "yes" ]; then
		grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
	else
		gurb-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	fi
else
	echo "Buy an UEFI system"
fi
echo ""
echo -n "Let's now generate the config (press enter to continue)"
read
grub-mkconfig -o /boot/grub/grub.cfg

