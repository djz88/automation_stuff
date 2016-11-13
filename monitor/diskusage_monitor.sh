#!/bin/bash
#---------------------------------------
#### START      HEADER
## script for copy dumped databases to remote location by Zdenek K <n1djz.88@ygg.cz>
## usage ./remote_backup_mysql.sh
## debug option
##set -x
## TO DO
## 
#### END        HEADER
#---------------------------------------

#### START      FUNCTIONS DECLARATION
#### END        FUNCTION DECLARATION

#### START      BASIC VARIABLES
HOSTNAME=`hostname -f`
EMAIL_SUBJECT="disk usage on $HOSTNAME"
EMAIL_ADDRESS="email@here"
#### END        BASIC VARIABLES

#### START      ARGUMENT PARSING
#### END	ARGUMENT PARSING

#### START      MAIN 

CMD=`df -h /dev/mapper/* | grep -v udev |egrep " [8-9][0-9]%"`
if [ $? -eq 0 ]; then echo -e $CMD | mailx -r diskusage@$HOSTNAME -s "$EMAIL_SUBJECT" $EMAIL_ADDRESS;fi

#### END	MAIN 
