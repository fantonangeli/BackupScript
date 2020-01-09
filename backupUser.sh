#!/bin/bash

#where to store your backups
backupDevice="/dev/mapper/backup"

#where to mount your backups device (you can leave this value)
backupRoot="/tmp/backup"

#directory name inside your backup device 
backupUserDir="$backupRoot/Username"


source `dirname $0`/backup.inc.sh

mountBackupPart

#use this command to backup encrypted volumes. Syntax "backupLuks [luks name] [fstype]"
backupLuks home ext4

#use this command to backup non encrypted volumes. Syntax "backup [dev name] [fstype]"
backupDev sda1 ext4

printStats

 
