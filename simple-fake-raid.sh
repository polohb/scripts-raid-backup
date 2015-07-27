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

# log file
readonly ERROR_FILE_PATH='./error.log'

# User email, diff synch will be send to this email
readonly MAIL=polohb@gmail.com

# Folder we want to sync
# Remark : if end by / only the content of the folder is copied
# else (no / at the end) the folder is copied (1 more lvl in dircetory tree)
readonly R1_SOURCE_FOLDER='/media/R1_DATA/'

# Destination folder (backuped data)
readonly R1_DEST_FOLDER='/media/R1_RSYNC'

# Create a mirror folder
# --delete-after : remove file in dest folder that are not in source folder
# -z : compress
# -v : verbose
# -e sssh : use ssh protocol
# some example
#rsync -avz --delete-after /home/source user@ip_du_serveur:/dossier/destination/
#rsync -av --delete-after $R1_SOURCE_FOLDER $R1_DEST_FOLDER 2> ./error.log

#OUTPUT=`rsync -av --delete-after $R1_SOURCE_FOLDER $R1_DEST_FOLDER`
#echo $OUTPUT | mail -s "$0 : run" $MAIL;

# > $ERROR_FILE_PATH 2>&1 : concat error and standart output to error file
rsync -av --delete-after ${R1_SOURCE_FOLDER} ${R1_DEST_FOLDER} > ${ERROR_FILE_PATH} 2>&1

# mail the log file to the $MAIL address
cat $ERROR_FILE_PATH | mail -s "$0 : run results" $MAIL;
