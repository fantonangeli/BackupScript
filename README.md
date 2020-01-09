# BackupScript

This is my personal script that I use together with Clonezilla live.
I share this for everyone who wants to use it.



# Setup

1. In the partition where you want to store your backups create a file with the filename ".backupHardDisk".
    This way the script will ensure you will not put backups in the wrong place ;-)
2. Create a usb key with Clonezilla and copy the scripts in the root of the key.
2. Open backupUser.sh and follow the instructions inside
3. In yor backupDevice create the folder with your Username according to the variable "backupUserDir" in the backupUser.sh



# Instructions

1. Start Clonezilla and enter the shell
2. cd /run/medium/live
3. If you have encrypted volumes open them without mount, with:
    cryptsetup luksOpen /dev/sda1 home
3. Run
    ./backupUser.sh
4. In the end of the process you will see the stats of the backup
