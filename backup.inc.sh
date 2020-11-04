#!/bin/bash

#testFile filename. This file MUST be in the backup directory to ensure that we are using the correct one
testFile=".backupHardDisk"

#simulation mode. Set to 1 to simulate the backup
simulationMode=0



# prints backup statistics
function printStats()
{
    printf 'Elapsed time: %s\n' $(timer $t)

    ls -lh $backupDir
}

# calculate and prints the time estimation for the execution
# @param number starting timestamp
# eg. t=$(timer)
#   printf 'Elapsed time: %s\n' $(timer $t)
function timer()
{
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

# prints a message and terminates the program (use with $LINENO to print the line number)
# @param string the message
#eg.  test || die "Error in line $LINENO"
die()
{
    echo "$1" >&2
    exit 1
} 


# mount the partition and do the checks
# @return 0 if everything ok, otherwise will terminate the program 
mountBackupPart(){
   local Ntentativo=0
   local retVal=0
   
   #checks
   if [ ! -b "$backupDevice" ]
   then
     die "The device $backupDevice doesn't exists!"
   fi
   
   mkdir $backupRoot 
   
   #checks if the directory exists
   if [ ! -d "$backupRoot" ]
   then
     die "Directory $backupRoot not found!"
   fi
   
   
   mount $backupDevice $backupRoot
   
   #checks if the testFile exists in the backup partition
   if [ ! -e "$testFilePath" ]
   then
     die "The device $backupDevice doesn't seem to be the right one!"
   fi
   
   #checks if the user directory exists in the backup partition
   if [ ! -d "$backupUserDir" ]
   then
     die "Directory $backupUserDir not found!"
   fi
   
   mkdir $backupDir
   
   #checks if the backup directory exists after creation
   if [ ! -d "$backupDir" ]
   then
     die "Unable to create the directory $backupDir!"
   fi
   
}


# does the backup for an encrypted device
# @param the device name (luks) to backup
# @param fs type
# @return the program will be terminated in case of error
backupLuks(){
  local inDevice="/dev/mapper/$1"
  local outFile="$backupDir/$1"
  local fstype=$2

  #checks-----------------
  if [ ! -n "$1" ]
  then
    die "Error calling $FUNCNAME: wrong param 1"
  fi

  if [ ! -n "$fstype" ]
  then
    die "Error calling $FUNCNAME: wrong param 2"
  fi
  
  backup $inDevice $outFile $fstype
}
# does the backup of a normal device
# @param the name of the device to backup (eg. sda1)
# @param fs type
# @return the program will be terminated in case of error
backupDev(){
  local inDevice="/dev/$1"
  local outFile="$backupDir/$1"
  local fstype=$2

  #precontrolli-----------------
  if [ ! -n "$1" ]
  then
    die "Error calling $FUNCNAME: wrong param 1"
  fi
  
  if [ ! -n "$fstype" ]
  then
    die "Error calling $FUNCNAME: wrong param 2"
  fi

  backup $inDevice $outFile $fstype
}

# does the backup of a device (not intended to be called directly, use backupDev or backupLuks instead)
# @param the name of the device to backup (full path)
# @param the device name for the backup
# @param fs type
# @return the program will be terminated in case of error
backup(){
  local inDevice=$1
  local outFile=$2
  local fstype=$3

  #checks-----------------
  if [ ! -b $inDevice ]
  then
    die "Error cannot find the device $1"
  fi

  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

  if [ "$simulationMode" -eq 0 ]; then
      eval "partclone.$fstype -c -s $inDevice -o $outFile || die \"Error during the backup of $1\""
  else
      echo "partclone.$fstype -c -s $inDevice -o $outFile"
  fi
  
  echo "Backup of $1 done correctly"
  
}







#-----------------------------------------------------------------------------
#system vars
data=`date +%Y%m%d`
testFilePath="$backupRoot/$testFile"
backupDir="$backupUserDir/$data"
t=$(timer)
