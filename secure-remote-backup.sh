#!/bin/bash
# Auteur :  polohb@gmail.com
#
# File : secure-remote-backup.sh
#
# Based on : http://jc.coynel.net/2013/08/secure-remote-backup-with-openvpn-rsync-and-encfs/
#

# Define some vars

# Only users with $UID 0 have root privileges.
readonly ROOT_UID=0

# Directory where encfs_config  and pwd files are stored
readonly CONFIG_FILES_DIR="/home/polohb"

# encfs config file (this file is used to encryt and decrypt)
readonly ENCFS6_CONFIG=${CONFIG_FILES_DIR}/.encfs6.xml
export ENCFS6_CONFIG

# password file (used to encryt and decrypt with encfs file)
readonly PASSWORD_FILE=${CONFIG_FILES_DIR}/.pwd_encryt_bkp

# Virtual encryted folder that match real folder (take no space)
readonly VIRTUAL_ENCRYPTED_FOLDER=/tmp/encryted_folder

# Upload bandwidth limit in KBytes per second
# Do not put max upload connection to be able to do other things ;)
readonly BWLIMIT='5000' # 5 MB/s

# Server address
readonly SERVER=yourhost.com


# function fn_delete_virtual_encryted_folder
# Try deleting VIRTUAL_ENCRYPTED_FOLDER when it is umount
# no params
fn_delete_virtual_encryted_folder() {
if [[ "$(ls -A $VIRTUAL_ENCRYPTED_FOLDER )" ]]; then
  echo ""
  echo "Encrypted folder ($VIRTUAL_ENCRYPTED_FOLDER) is not empty ..."
  echo "Bye"
  exit 1
else
  rm -rf $VIRTUAL_ENCRYPTED_FOLDER
  echo ""
  echo "Encrypted folder ($VIRTUAL_ENCRYPTED_FOLDER) is now deleted"
fi
}

# fuction fn_mount_encrypted_folder
# $1 : source folder that will be encryted
fn_mount_encrypted_folder() {
  echo ""
  echo "Mount $1 as encrypted $VIRTUAL_ENCRYPTED_FOLDER"
  cat $PASSWORD_FILE | encfs -S --reverse $1 $VIRTUAL_ENCRYPTED_FOLDER
  if [[ $? -ne 0 ]]; then
    echo ""
    echo "Error while mounting the encrypted folder (($VIRTUAL_ENCRYPTED_FOLDER) on $1, exiting."
    exit 1
  fi
}

# fuction fn_mount_encrypted_folder
# Trying umount VIRTUAL_ENCRYPTED_FOLDER
fn_unmount_encrypted_folder() {
  echo ""
  echo "Search if $VIRTUAL_ENCRYPTED_FOLDER is mounted..."
  mount | grep $VIRTUAL_ENCRYPTED_FOLDER
  if [[ $? -eq 0 ]]; then
    echo "The encrypted folder ($VIRTUAL_ENCRYPTED_FOLDER) is currently mounted, unmounting..."
    umount $VIRTUAL_ENCRYPTED_FOLDER
    if [[ $? -ne 0 ]]; then
      echo "Error while unmounting the encrypted folder ($VIRTUAL_ENCRYPTED_FOLDER), aborting."
      exit 1
    fi
    echo "Encrypted folder ($VIRTUAL_ENCRYPTED_FOLDER) is now unmounted."
  else
    echo "Encrypted folder ($VIRTUAL_ENCRYPTED_FOLDER) was not mounted, continue ..."
  fi
}

# fuction fn_rsync_folder
# Backup encrypted_folder to server
# $1 : encrypted dest folder on the server
fn_rsync_folder() {
  echo ""
  echo "Synch encryted folder to the sever ..."
  # The rsync .TEMP folder must exist on the destination !
  # If backup folder is /home/backup/$1 the .TEMP can be : /home/backup/.TEMP
  rsync --archive --progress --numeric-ids --bwlimit=${BWLIMIT} -T /.TEMP $VIRTUAL_ENCRYPTED_FOLDER/ rsync://${SERVER}/backup${1}
}

# fucntion fn_backup_folder
# $1 : source folder to be backuped
# $2 : dest folder (encryted and on the server)
fn_backup_folder() {
  fn_mount_encrypted_folder $1
  fn_rsync_folder ${2}
  fn_unmount_encrypted_folder
}


fn_check_env() {
  # Run as root, of course.
  if [[ "$UID" -ne "$ROOT_UID" ]]; then
  then
    echo "Need to be root to run this script."
    exit 1
  fi

  # Test encfs config exist
  if  [[ ! -f "$ENCFS6_CONFIG" ]]; then
    echo "$ENCFS6_CONFIG does not exist or is not a valid file"
    exit 1
  fi

  # Test password file exist
    echo "$PASSWORD_FILE does not exist or is not a valid file"
  if  [[ ! -f "$PASSWORD_FILE" ]]; then
    exit 1
  fi

  # Purge virtual directory if exists
  if [[ -d "$VIRTUAL_ENCRYPTED_FOLDER" ]; then
    unmount_encrypted_folder
  else
    mkdir $VIRTUAL_ENCRYPTED_FOLDER
  fi

}


fn_prepare_env() {
  mkdir $VIRTUAL_ENCRYPTED_FOLDER
  encfs --reverse . $VIRTUAL_ENCRYPTED_FOLDER
}



main() {

  if [[ "$1" -ne "--prepare" ]]; then

    fn_prepare_env

  else

    # check env
    fn_check_env

    # Backup R1_DATA folder
    fn_backup_folder /media/R1_DATA /enc-view-r1-data

    # Backup another folder
    #fn_backup_folder SOURCE DEST

    fn_delete_virtual_encryted_folder

  fi

}

# Start :D
main
