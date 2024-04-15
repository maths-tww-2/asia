#!/bin/bash

#Made by: Maths and itsgerliz
#This project and its respective files are protected by the GNU General Public License 3 (read LICENSE)

echo "Let's configurate the new system!"
echo "Ths script must be ran with an arch-chroot"
echo "If this is not your case, cancel now"
echo -n "Let's start with the locales (enter to continue)"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo -n "You can also configurate the language and keyboard layour later, but this script does not do it yet. Let's continue with the users and passowrds. [Enter to continue]"
read a
passwd
echo ""
echo "You set the password of the root, now let's create a user"
echo -n "How would you want to name the new user? [user name]:"
read user
useradd $user
passwd $user
echo ""
echo "It is done. Now we have to create the bootloader with the next script"
echo -n "Do you want me to execute it? [yes/no]:"
read answer
if [ "$answer" == "yes" ]; then
	./bootloader.sh
fi
