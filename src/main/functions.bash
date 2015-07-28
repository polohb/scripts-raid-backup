#!/bin/bash
# Auteur :  polohb@gmail.com
#
# File : functions.bash
#


# Error msg to stderr not stdout
errcho(){
  >&2 echo $@
}

# Create a mirror folder
sync_folder(){

  local r1SourceFolder="$1/";
  local r1DestFolder=$2;
  local errorFilePath=$3;

  if [[ "$#" -ne "3" ]];then
    errcho "need at least 3 args"
    return 1;
  fi

  if [[ ! -d ${r1SourceFolder} ]]; then
    errcho "source is not a folder"
    return 1;
  fi

  if [[ ! -d ${r1DestFolder} ]]; then
    errcho "dest is not a folder"
    return 1;
  fi

  if [[ -e ${errorFilePath} &&  ! -f ${errorFilePath} ]]; then
    errcho "log file is not file"
    return 1;
  fi


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
  local errorFilePath=$1;
  local userEmail=$2;
  # mail the log file to the $MAIL address
  cat ${errorFilePath} | mail -s "$0 : run results" ${userEmail};
}
