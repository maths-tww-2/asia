#!/bin/bash

# Made by: Maths and itsgerliz
# This project and its respectives files are protected by the GNU General Public license 3 (read LICENSE)

echo ""
echo "This is the partitioning script. We will start by selecting the boot type of your computer"
while true; do
	echo -n "Your cumputer has: [BIOS/UEFI]"
	read bootype
	if [ "$bootype" == "BIOS" ]; then
		break
	elif [ "$bootype" == "UEFI" ]; then
		break
	else
		echo "$bootype is not a valid option... restarting."
	fi
done
echo "The boot type is $bootype"
echo "These are your disks:"
lsblk
echo -n "Where are you going to install arch?: /dev/"
read disk
if [ "$bootype" == "BIOS" ]; then
	parted -s /dev/$disk mklabel msdos
	parted -s /dev/$disk unit GB mkpart primary ext4 0% 100%
	lsblk
	echo -n "Enter your root partiion: /dev/"
	read root
	mkfs.ext4 /dev/$root
else
	parted -s /dev/$disk mklabel gpt
	parted -s /dev/$disk unit GB mkpart mainroot ext4 1GB 100%
	parted -s /dev/$disk unit GB mkpart efiboot fat32 0% 1GB
	parted -s /dev/$disk unit GB set 2 esp on
	echo "Now let's make the file systems"
	lsblk
	echo -n "Which is your boot partition? /dev/"
	read boot
	mkfs.fat -F /dev/$boot
	lsblk
	echo -n "Which is your root partition? /dev/"
	read root
	mkfs.ext4 /dev/$root
fi


echo "Filesystems are done. You can run the next script, pacstrap. Do not forget to mount first!"
echo -n "Do you want me to start pacstrap.sh?"
read answer 
if [ "$answer" == "yes" ]; then
	mount /dev/$root /mnt
	if [ "$bootype" == "UEFI" ]; then
		mount /dev/$boot /mnt/boot
	fi
	./pacstrap.sh
else
	echo "Next script won't be executed. Make sure to mount your partitions before executing it yourself!"
fi


