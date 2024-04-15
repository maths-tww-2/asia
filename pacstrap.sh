#!/bin/bash

# Made by: Maths and itsgerliz
# This project and its respectives files are protected by the GNU General Public License 3 (read LICENSE)

echo "We are now going to install the essential packages"
lsblk
echo -n "Where did you mount the root partition? /"
read folder
echo "Let's install the essential packages"
pacstrap -K /$folder linux linux-firmware sof-firmware base kitty parted networkmanager nano 
echo -n "Essential packages were installed. Let's generate the config [press enter to continue]"
read
genfstab -U /$folder >> /$folder/etc/fstab
echo "It was generated"
echo "You can now execute the next script, config.sh, after doing 'arch-chroot /$folder "
echo "Do you want me to move the config.sh script inside the new root?"
read answer
if [ "$answer" == "yes" ]; then
	cp config.sh /$folder
	cp bootloader.sh /$folder
	echo "It was moved"
fi 
echo "Now we will enter the chroot. Then you must run config.sh"
arch-chroot /$folder



