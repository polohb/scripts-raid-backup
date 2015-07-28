# Simple Fake Raid & Secure Remote Backup


## Simple Fake Raid (with rsync)

Like a fully raid is not essential for me, I have made this script to mirroring some data I wanted to backup.

I call it *fake raid* because the mirroring is not immediate and is only made one time a week (simple cron task).

This is not a *real backup* as data deleted on the source folder will be deleted on the *fake raid* destination folder.

### Prerequisite
First, you need to have rsync installed and a valid mail system on your OS.


### Configure the script
You should change some vars :

- the mail address where log file will be sent
```
userMail=user@mail.com
```

- the source folder (this is the folder we want to sync)

```
# Should en with / (only the content of the folder will be copied)
r1SourceFolder='/media/FOLDER_WE_WANT_TO_SYNC/'
```

- the destination folder
```
r1DestFolder='/media/BACKUP_DATA_FOLDER'
```

### Use the script

You can simply run the script via a shell : `bash simple-fake-raid.bash`

You can also use a cron task like this :
```
# launch @ 05h00 every sunday
0 5 * * 7 /home/polohb/scripts-raid-backup/src/main/simple-fake-raid.bash
```



## Secure Remote Backup (with rsync, encfs)

The script and instructions are based on : [jc.coynel notes](http://jc.coynel.net/2013/08/secure-remote-backup-with-openvpn-rsync-and-encfs/).


### Prerequisite

#### Local machine
You need **rsync** and **encfs** installed.

Then prepare the environment :

 - select the location of the .encfs6.xml by setting the ENCFS6_CONFIG environment variable
```
ENCFS6_CONFIG=/home/polohb/.encfs6.xml
```

- create a first virtual encrypted folder and when encfs ask questions,  chose :
 * expert mode `x`
 * AES 256 bits `1 and 256`
 * 1024 byte file system `1024`
 * encryption of file names `1`
 * enter your password twice
```
 mkdir /tmp/encryted_folder
 encfs --reverse . /tmp/tmp/encryted_folder
```

- save your password in a file if you want to use the automated script :
```
echo "mypassword" > ~/.pwd_encryt_bkp
chmod 600 ~/.pwd_encryt_bkp
```

- do not forget to umount and delete the encryted_folder



#### Remote server
You need **rsync** enabled in **daemon mode**.

- enable it in /etc/default/rsync :
```
RSYNC_ENABLE=true
```

- then configure the rsync dameon in /etc/rsyncd.conf file :
```
log file = /var/log/rsync.log
timeout = 300
read only = yes
[backup]
comment = Backup folder
path = /home/backup
read only = no
list = yes
uid = root
gid = root
host allow = YOUR_IP_HERE
host deny = *
```

 - and create the rsync tmp folder :
```
mkdir -p /home/backup/.TEMP
````



### Configure the script
You may change some vars :

- directory where **encfs\_config_file**  and **password** files are stored
```
CONFIG_FILES_DIR="/home/polohb"
```

- upload bandwidth limit in KBytes per second
```
BWLIMIT='5000' # 5 MB/s
```

- server address
```
SERVER=yourhost.com
```

### Use the script

You can simply run the script via a shell as root user : `bash secure-remote-backup.sh`
