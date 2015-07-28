#!/bin/bash
# Auteur :  polohb@gmail.com
#
# File : Test.sh
#
#

# Source funtions
. ../main/functions.bash

test_SyncFolder_Fail_NoParam(){
  # Fail test if no argument
  sync_folder > /dev/null 2>&1
  local returnCode=$?
  assertEquals "Script should fail when no argument" 1 $returnCode
}

test_SyncFolder_Fail_1stParamNotAFolder(){
  # prepare
  touch toto tata

  sync_folder toto /tmp/ tata > /dev/null 2>&1
  returnCode=$?
  assertEquals "Script should fail when 1st params is not a folder" 1 $returnCode

  # delete created files
  rm toto tata
}

test_SyncFolder_Fail_2ndParamNotAFolder(){
  # prepare
  touch toto tata

  sync_folder  /tmp/ toto tata > /dev/null 2>&1
  local returnCode=$?
  assertEquals "2nd params is not a folder" 1 $returnCode

  # delete created files
  rm toto tata
}

test_SyncFolder_Fail_3rdParamIsFolder(){
  sync_folder /tmp/ /tmp/ /tmp/ > /dev/null 2>&1
  local returnCode=$?
  assertEquals "3rd params is not a file" 1 $returnCode
}


test_SyncFolder_Success_NoDiff(){
  # prepare
  touch log
  mkdir tmp1 tmp2
  echo "azdazd" > tmp1/toto

  sync_folder tmp1 tmp2 log > /dev/null #2>&1
  diff tmp1 tmp2
  local returnCode=$?
  assertEquals "Source and Dest shloud equals" 0 $returnCode

  # delete created files
  rm -rf tmp1 tmp2 log
}

#TODO testMailLog




. shunit2
