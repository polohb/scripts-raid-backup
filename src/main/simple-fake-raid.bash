#!/bin/bash
# Auteur :  polohb@gmail.com
#
# File : simple-fake-raid.bash
#
#
# You can use this script via a cron task
# launch @ 05h00 every sunday
# 0 5 * * 7 /root/scripts-raid-backup/src/main/simple-fake-raid.sh
#

# Source pkg
. ./functions.bash


main(){
  # log file
  local errorFilePath='./error.log'

  # User email, diff synch will be send to this email
  local userMail=polohb@gmail.com

  # Folder we want to sync
  # Remark : if end by / only the content of the folder is copied
  # else (no / at the end) the folder is copied (1 more lvl in dircetory tree)
  local r1SourceFolder='/media/R1_DATA/'

  # Destination folder (backuped data)
  local r1DestFolder='/media/R1_RSYNC'

  sync_folder ${r1SourceFolder} ${r1DestFolder}  ${errorFilePath}
  mail_log ${errorFilePath} ${userMail}
}


main
