#!/bin/bash
# Auteur :  polohb@gmail.com
#
# File : simple-fake-raid.sh
#
#
# You can use this script via a cron task
# launch @ 05h00 every sunday
# 0 5 * * 7 /root/scripts-raid-backup/simple-fake-raid.sh
#




# Create a mirror folder
sync_folder(){
  local r1SourceFolder = $1;
  local r1DestFolder = $2;
  local errorFilePath = $3;

  # --delete-after : remove file in dest folder that are not in source folder
  # -z : compress
  # -v : verbose
  # -e sssh : use ssh protocol
  # some example
  #rsync -avz --delete-after /home/source user@ip_du_serveur:/dossier/destination/
  #rsync -av --delete-after $R1_SOURCE_FOLDER $R1_DEST_FOLDER 2> ./error.log
  # > $errorFilePath 2>&1 : concat error and standart output to error file
  rsync -av --delete-after ${r1SourceFolder} ${r1DestFolder} > ${errorFilePath} 2>&1
}

mail_log() {
  local errorFilePath = $1;
  local userEmail = $2;
  # mail the log file to the $MAIL address
  cat ${errorFilePath} | mail -s "$0 : run results" ${userEmail};
}


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
