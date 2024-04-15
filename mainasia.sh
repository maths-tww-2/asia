#!/bin/bash

#Authors -> itsgerliz and Maths
#This project and its respective files are protected by the GNU General Public License 3 (read LICENSE)

#Declaration of some variables for future use
abort=""
bootype=""
swapsize=0
mountfolder=""
editor=""

#Some messages for the user
echo ""
echo "// Welcome to ASIA, the ArchLinux simplified installation assistant //"
echo "!!! Currently we do not support 32bit UEFI platforms !!!"
echo "!!! Currently we do not support separate /home partition !!!"
echo "!!! Currently we do not support LVM, system encryption or RAID !!!"
echo "!!! This script is supposed to work on a EMPTY disk !!!"
echo "!!! If your disk is NOT empty, it will work but you must know that all the data in it will be DESTROYED !!!"
echo "!!! This script is made for x86_64 BIOS or UEFI since ArchLinux does not support other CPU architectures !!!"
echo -n "// Read this info carefully before proceeding // (Enter to continue)"
read #Checkpoint
echo "!!! This script assumes you are executing this inside: !!!"
echo ""
echo "1 -> The ArchISO"
echo "2 -> A Linux system with the <arch-install-scripts> package available"
echo ""
echo "If this is not your case abort now"

#Beginning of the abort decision loop
while [ -z $abort ]; do #This won't let the user continue until he inputs something valid, it evaluates if the string is empty (0 len)
	echo -n "Abort? [yes/no]: " #Prompt abort decision to the user, possible options: "yes"/"no"
	read abort #This reads the input from the user and saves it inside the abort variable
	echo ""
	if [ "$abort" = "yes" ]; then #This conditional evaluates if abort variable is equal to "yes"
		echo "Aborting..."
		exit #If it is, "Aborting..." will be prompted and the script will be killed
	elif [ "$abort" = "no" ]; then #This conditional evaluates if abort variable is equal to "no"
		echo "Proceeding..." #If it is "Proceeding..." will be prompted and the loop will be exited because abort variable is no longer empty
	else #If the input is not equal to "yes" or "no" (any other input, even enter) a warning will be prompted, then the variable abort will be set again to an empty string so that the loop will continue
		echo "Not a valid option, take care of the capital letters"
		abort=""
	fi #This ends the conditional block
done

#Parts of the installation process
echo ""
echo "The installation process is divided in the following parts:"
sleep 0.4
echo "-1 -> Way to boot"
sleep 0.4
echo "-2 -> Check for internet connection"
sleep 0.4
echo "-3 -> Disk parititioning"
echo "    -3.1 -> Choose disk label"
echo "    -3.2 -> Choose swap size"
echo "    -3.3 -> Root partition"
sleep 0.4
echo "-4 -> Creation of the filesystems"
sleep 0.4
echo "-5 -> Mounting of the filesystems"
sleep 0.4
echo "-6 -> Installation of packages to the new sistem via PACSTRAP"
echo "    -6.1 -> Personal packages choices"
echo "    -6.2 -> CPU Microcode"
sleep 0.4
echo "-7 -> Configuration of the new system"
echo "    -7.1 -> File Systems Table (fstab)"
echo "    -7.2 -> Chroot into the new system"
echo "    -7.3 -> Time Zone"
echo "    -7.4 -> Locales"
echo "    -7.5 -> System network hostname"
echo "    -7.6 -> Root password"
echo "    -7.7 -> Creation of new users"
sleep 0.4
echo "-8 -> Boot software"
echo "    -8.1 -> Bootloader"
echo "    -8.2 -> Bootloader config"
sleep 0.4
echo "-9 -> Final phase"
echo "    -9.1 -> Exit chroot"
echo "    -9.2 -> Unmounting all filesystems"
sleep 0.4
echo -n "Your new ArchLinux system! (Enter to continue)"
read #Just a checkpoint
echo ""

#Beginning of the way to boot section
echo "// Boot type //"
echo ""

while [ -z $bootype ]; do #This won't let the user continue until he inputs something valid, it evaluates if the string is empty (0 len)
	echo -n "Will your system boot in UEFI or BIOS? [UEFI/BIOS]: " #Prompt boot type to the user, possible options: "UEFI"/"BIOS"
	read bootype #This reads the input from the user and saves it inside the bootype variable
	if [ "$bootype" = "UEFI" ]; then #This conditional evaluates if bootype variable is equal to "UEFI"
		echo ""
		echo "Selected boot type: $bootype"
		echo ""
	elif [ "$bootype" = "BIOS" ]; then #This conditional evaluates if bootype variable is equal to "BIOS"
		echo ""
		echo "Selected boot type: $bootype"
		echo ""
	else #If the input is not equal to "UEFI" or "BIOS" (any other input, even enter) a warning will be prompted, then the variable bootype will be set again to an empty string so that the loop will continue
		echo "'$bootype' is not a valid option, take care of the capital letters"
		bootype=""
	fi #This ends the conditional block
done

#Check for internet connection
echo "// Internet Check //"
echo ""

wget -q --spider https://www.google.com/ #The wget command will check google website availability without output and download (wget must be installed, if not installed the script will abort)
if [ $? -eq 0 ]; then #This conditional will evaluate the shell return code, if it is 0, no error was reported so internet is reachable, if anything else, an error was reported during the wget so internet is unreachable
	echo "Online, internet is reachable"
else
	echo "Offline, internet is unreachable"
	echo "Aborting..."
	exit #If internet is unreachable, abort the script
fi

# Beggining of the partitioning
sleep 0.4 # Delay
echo ""
echo "// Partitioning //" 
echo ""

##Selecting the disk device
while true; do # Start of the loop
	sleep 0.4 # Delay
	echo "These are your disks:"
	lsblk # Show disks
	echo ""
	echo "The following input is VERY IMPORTANT, we won't check if the selected disk is well-written or if it is the correct one"
	echo "We will ask you for confirmation later so this is not DEFINITIVE"
	echo ""
	echo -n "Which is the DISK (NOT partition(/dev/sda, NOT /dev/sda1)) you want to format?: /dev/"
	read diskdevice # Read user input and assign it to diskdevice variable
	echo "The selected disk to format is /dev/$diskdevice"
	echo "NOW its definitive, if u say yes here and there is something incorrect there is no way back, BEWARE"
	echo -n "Are you sure? [yes/no]: " # Make sure the user wants
	read diskconfirm #Save decision inside diskconfirm variable
	echo ""
	if [ "$diskconfirm" = "yes" ]; then #If diskconfirm = "yes" (sure) then
		found=$(find /dev/$diskdevice)
		if [ "$found" = "/dev/$diskdevice" ]; then
			echo "That disk exists, proceeding..."
			echo ""
			break #Break the loop and proceed with the following step
		fi
	fi
	echo ""
	echo "You said no, typed an invalid option or the selected disk does not exist, restarting the prompt..."
	echo ""
done # End of loop, it will loop until something breaks it

##Creating the disk label
if [ "$bootype" = "UEFI" ]; then #If the boot type is UEFI, a GPT label will be created on the disk
	echo "We will create a GPT partition table on your disk because you chose UEFI boot type before"
	parted -s /dev/$diskdevice mklabel gpt
	echo "Done!"
elif [ "$bootype" = "BIOS" ]; then #If the boot type is BIOS, a MSDOS(MBR) label will be created on the disk
	echo "We will create a MSDOS(MBR) partition table on your disk because you chose BIOS boot type before"
	parted -s /dev/$diskdevice mklabel msdos
	echo "Done!"
fi

##Choosing partition layout
###If UEFI, won't ask for a ESP because it's mandatory
###Will ask if the user wants swap area or not
echo ""
if [ "$bootype" = "UEFI" ]; then
	parted -s /dev/$diskdevice unit GB mkpart efiboot fat32 0% 1GB
	parted -s /dev/$diskdevice unit GB set 1 esp on
	echo "(The ESP partition (1GB) has been created because you selected UEFI as the boot type before)"
fi

####Swap decision
echo ""
echo "Now you must decide how do you want to partition the disk"
while true; do #Start of the loop, will loop if the user does not input a valid option
	echo -n "Do you want to create a swap area? [yes/no]: "
	read swapdecision #Save decision in swapdecision variable
	if [ "$swapdecision" = "yes" ]; then #If decision is equal to "yes" it will ask for the size
		echo -n "How much space do you want to give for the swap area? (just the number)[measured in GB]: "
		read swapsize #Asks for an integer in GB as the swap size
		if [ "$bootype" = "UEFI" ]; then #
			startroot=$((swapsize+1)) # Calculates where does root partition start (1GB boot + swap)
			parted -s /dev/$diskdevice unit GB mkpart swaparea linux-swap 1GB $startroot
			echo "The swap area has been created, it finishes in $startroot GB"
			break
		elif [ "$bootype" = "BIOS" ]; then #
			parted -s /dev/$diskdevice unit GB mkpart primary linux-swap 0% $swapsize
			echo "The swap area has been created, it finishes in $swapsize GB"
			break
		fi
	elif [ "$swapdecision" = "no" ]; then #If decision is equal to "no" skip to the next step breaking the loop
		echo "Skiping..."
		break
	else #If decision is not "yes" or "no" print a warning and loop again
		echo "Not a valid option"
	fi #End of the conditional block
done #End of the loop

###Root partition
echo "// Root partition //"
echo ""
echo -n "Now we will create the root partition... (Enter to continue) :"
read #Checkpoint
echo ""
if [ "$bootype" = "UEFI" -a "$swapdecision" = "yes" ]; then # UEFI with swap area
	parted -s /dev/$diskdevice unit GB mkpart mainroot ext4 $startroot 100%
elif [ "$bootype" = "UEFI" -a "$swapdecision" = "no" ]; then # UEFI with NO swap area
	parted -s /dev/$diskdevice unit GB mkpart mainroot ext4 1GB 100%
elif [ "$bootype" = "BIOS" -a "$swapdecision" = "yes" ]; then # BIOS with swap area
	parted -s /dev/$diskdevice unit GB mkpart primary ext4 $swapsize 100%
elif [ "$bootype" = "BIOS" -a "$swapdecision" = "no" ]; then # BIOS with NO swap area
	parted -s /dev/$diskdevice unit GB mkpart primary ext4 0% 100%
fi

echo "The partitions have been created."
echo ""
parted -s /dev/$diskdevice print # Show the partitions
echo ""

# Making filesystems ##WORKING## ##DO NOT TOUCH ANYTHING ON FILESYSTEMS## (ask itsgerliz)
echo "// Filesystems creation //" 
echo ""
echo -n "We will now create the file systems. [Press Enter to continue:]"
read # A checkpoint
echo "We need you to specify where (partition) to create each filesystem"

while true; do
	echo "Now you will be asked for the partition of each filesystem"
	echo "Here is the info, in the device column you can see the identifier of each partition"
	fdisk -l /dev/$diskdevice
	if [ "$bootype" = "UEFI" ]; then
		echo -n "Which is the boot partition(ESP)(example: nvme0n1p1 -> /dev/"
		read bootpartitionuefi
		foundboot=$(find /dev/$bootpartitionuefi)
		if [ "$foundboot" = "/dev/$bootpartitionuefi" ]; then
			echo ""
			echo "That partition exists, proceeding..."
			echo ""
		else
			echo "That partition does not exist"
		fi

	fi
done


if [ "$bootype" = "UEFI" ]; then # Check the boot type 
	mkfs.fat -F 32 "/dev/$(diskdevice)1" # Make fat32 file system for the first partition (boot)
	if [ "$swapdecision" = "yes" ]; then # Check if the swap was created
		mkfs.ext4 "/dev/$(diskdevice)3" # Make ext4 file system for root
		mkswap "/dev/$(diskdevice)2" # Make swap FS for swap
	else # If there is not swap
		mkfs.ext4 "/dev/$(diskdevice)2" # Make ext4 FS to root
	fi
fi

if [ "$bootype" = "BIOS" ]; then # If they use BIOS
	if [ "$swapdecision" = "yes" ]; then # And have swap...
		mkfs.ext4 "/dev/$(diskdevice)2" # Make ext4 fs for root
		mkswap "/dev/$(diskdevice)1" # Make swap fs for swap partition
	else # If they do not have swap
		mkfs.ext4 "/dev/$(diskdevice)1" # Make the fs for the root partition
	fi
fi


echo "The FileSystems are done. Let's mount the partitoins."

###Mounting


echo ""
echo "// Mounting //"

while true; do # Start a bucle
	echo ""
	echo -n "Where do you want to mount the partitions? We recommend /mnt: "
	read mountfolder # Save the folder in a variable
	if [ "$mountfolder" = "/" ]; then # If the folder is /
		echo "Please, enter a valid folder" 
	elif [ "$mountfolder" = "/boot" ]; then # If the folder is /boot
		echo "Please, enter a valid folder"
	else # If it is not these...
		echo -n "Are you sure you want to mount your own system on $mountfolder ? It must be an empty folder like /mnt. [yes/no]" # Ask for confirmation
		read mountconfirm
		if [ "$mountconfirm" = "yes" ] # If the user confirms
			echo "Mounting..." 
			if [ "$bootype" = "BIOS" ]; then # If the user has BIOS
				if [ "$swapdecision" = "yes" ]; then # And created swap
					mount "/dev/$(diskdevice)2" $mountfolder 
					swapon "/dev/$(diskdevice)1"
				else # If did not create swap
					mount "/dev/$(diskdevice)1" $mountfolder
				fi
			fi
			if [ "$bootype" = "UEFI" ]; then # If the user has UEFI
				if [ "$swapdecision" = "yes" ] # If the user uses swap
					mount "/dev/$(diskdevice)3" $mountfolder
					mount --mkdir "/dev/$(diskdevice)1" "$(mountfolder)/boot"
					swapon "/dev/$(diskdevice)2"
				else # If the user does not have swap
					mount "/dev/$(diskdevice)2" $mountfolder 
					mount --mkdir "/dev/$(diskdevice)1" "$(mountfolder)/boot"
				fi
		
			fi
			break #Exit bucle if the user confirmed after mounting
		else # If the user did not confirm, it won't exit the bucle and will restart
			echo "Restarting mounting process..."
			echo ""
		fi

	fi
done # End of loop

echo "Partitions were mounted"
echo ""

### Pacstrap


echo "// Pacstrap //"
echo ""
echo -n "We will install essential packages now."
read
echo "Installing base, linux, and linux-firmware..."
pacstrap -K $mountfolder linux linux-firmware base # Install essential packages


echo ""
echo "We installed essential packages, now let's install other important packages."
echo "To install processor ucode, we need to know which is your processor..."
while true; do	# Start loop
	echo -n "Processor: [amd/intel]: " # Ask the user's processor and store it in a variable
	read processor 
	if [ "$processor" = "intel" ]; then # If it is intel stop loop
		break
	elif [ "$processor" = "amd" ]; then # If it is amd stop loop
		break
	else # If it is not intel or amd, it is an invalid option and the loop will restart
		echo ""
		echo "You did not enter a valid cpu, try again" # Warn the user
		echo "Restarting..."
		sleep 1
		echo ""
	fi
done # End of loop

echo "You chose $processor. "
sleep 1
echo ""

while true; do # Start loop
	echo "Let's choose text editor now. Which is your favourite text editor? We recommend 'nano'."
	echo -n "Text editor (leave blank if you don't want an editor): "
	read editor # Store user's editor choice in a variable
	echo "You selected $editor, are you sure you want to install $editor ? [yes/no]" # Ask for confirmation
	read editorconfirm
	if [ "$editorconfirm" = "yes" ]; then # If the user confirmed
		echo "Your text editor will be $editor "
		break # Sotp loop
	else # If the user did not confirm
		echo "You answered no, or typed an invalid option." # Warn the user
		echo "Restarting..."
		sleep 1
		echo ""
	fi 
done # End of loop

while true; do # Start bucle
	echo "We will now choose the partitioning tool."
	echo -n "Do you prefer 'Parted' or 'fsck'? [parted/fsck]: "
	read partitiontool # Sotre partitions tool on a variable
	if [ "$partitiontool" = "parted" ] then 
		break
	elif [ "$partitiontool" = "fsck" ] then
		break
	else # If the tool was not one of these, restart
		echo "You typed an invalid option, restarting..."
		sleep 1
	fi
done # End of bucle

echo ""
echo "Now let's install them!" 
sleep 2
pacstrap -K $mountfolder $partitiontool $editor "$(processor)-ucode" networkmanager sof-firmware man-db man-pages texinfo # Installs the user selected packages & man packages
sleep 1 
echo ""
echo " The next packages were isntalled: $partitiontool , $editor , $(processor)-ucode , networkmanager , sof-firmware , man-d , man-pages , texinfo ." # Warns the user about the installed packages
sleep 2
while true; do # Start bucle to ask if they want other packages
	echo ""
	echo -n "Do you want to install any other package? [yes/no]:"
	read answer
	if [ "$answer" = "yes" ]; then # If they want, continue
		echo -n "Which package would you like to install? [package]:"
		read extrapkg # Store user's package
		echo - n "Are you sure you want to install $extrapkg ? We won't check if it exists [yes/no]: "
		read answerr # Make sure he wants
		if [ "$answerr" = "yes" ]; then # If they're sure
			pacstrap -K $mountfolder $extrapkg # Install the package
			break # Stop bucle
		else # If they are not sure
			echo "You are not sure, or typed an invalid option. Restarting..."
			sleep 1
		fi
	elif [ "$answer" = "no" ]; then # If they do not want packages
		echo "Skipping process..."
		sleep 1
		break
	else # if they did not type yes or no
		echo "Please select a valid option"
		echo "Restarting..."
		sleep 1
	fi
done # End of loop

### Configuring

echo ""
echo "// Configuring the system //"
echo ""
echo "Now let's generate the fstab config."
genfstab -U $mountfolder >> "$(mountfolder)/etc/fstab" # Generates fstab configuration
echo "Fstab config has been generated." 
echo "Let's do a chroot now..."

### Chroot

arch-chroot $mountfolder # Enter the new system
echo "We are now inside the new system!"


sleep 1
echo -n "What would you want the hostname to be? (your computer name, we recommend short and one word names): [hostname]: "
read hostname 
echo $hostname >> /etc/hostname # Write the hostname into the file
echo -n "We are now going to generate the timezone and hour. Which is your country? (first capital letter): [Country]: "
read country
echo -n "Which is your country's capital (first capital letter)?"
read capital
ln -sf "/usr/share/zoneinfo/$(country)/$(capital)" /etc/localtime # Generate timezone
hwclock --systohc # Adjust clock
echo "The hour is set up." 
echo -n "Let's create the users and passwords! (Press Enter to continue):"
read
echo ""
while true; do # Start bucle to ask for password
	echo "We are going to set up root's password first. Root is the user with all permissions. Make sure the password is secure, and you remember it."
	echo "Enter Root password:"
	passwd
	break
done

echo ""
echo "Now we can create the users"
echo "Would you want to add a user? [yes/no]:"
read answer 
if [ "$answer" = "yes" ]; then # If they want to add a user
	echo -n "Which will be the name of the user? [Name]:"
	read name
	useradd $name # Add a user
	echo "A user called $name was created."
	while true; do
		echo "Type the password of $name"
		passwd $name
		break
	done # End of bucle
else # If they don't want a new user
	echo "No users were added"
fi
echo ""

while true; do
	echo -n "Do you want to give sudo permissions to $name ? (We recommend so) [yes/no]: "
	read answer
	if [ "$answer" = "yes" ]; then
		echo "Let's install sudo first."
		echo ""
		sleep 2
		pacman -S sudo
		echo ""
		echo -n "Sudo package was installed."
		echo -n "Now we need to give sudo permission to $name (Press Enter to continue):"
		read
		echo "$name   ALL=(ALL:ALL) ALL" >> /etc/sudoers
		echo ""
		echo "$name was added as sudoer"
		break
	elif [ "$answer" = "no" ]; then
		echo "$name won't have sudo permissions"
		break
	else
		echo "$answer is not a valir option, restarting..."
		sleep 2
	fi
done

echo ""

###Bootloader


echo "//Bootloader//"
echo ""
echo "Last step... The bootloader"
echo "We currently only support GRUB, since it's the most used bootloader"
echo "You must answer a question first:"
while true; do
 	echo -n "Are you installing arch on removable media (usbs, others)? [yes/no]:
	read removable"
 	if [ "$removable" = "yes" ]; then
  		echo "Let's install it now..."
    		sudo pacman -S grub efibootmgr
      		sleep 1
		if [ "$bootype" = "UEFI" ]; then

     		else
       		
  		fi
  		break
	elif [ "$removable" = "no" ]; then
  		echo "Let's install it now..."
    		sudo pacman -S grub efibootmgr
      		sleep 1
		if [ "$bootype" = "UEFI" ]; then

     		else
       		
  		fi
 		break
   	else
    		echo "$removable is not a valid option. Restarting..."
	fi
done



#///MESSAGE FOR THE DEVELOPERS///#
#///THIS SCRIPT IS NOT FINISHED///#
#///TEST THIS SCRIPT ON CONTROLLED ENVIRONMENTS///#
#///DO NOT TEST ON YOUR MAIN SYSTEM TO AVOID A DISASTER///#
