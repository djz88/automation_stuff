#!/bin/bash
#---------------------------------------
#### START      HEADER
## script for copy dumped databases to remote location by Zdenek K <n1djz.88@ygg.cz>
## usage ./remote_backup_mysql.sh
## debug option
##set -x
## TO DO                                                                                                                                                                                                           
## introduce cleanup function(e.g. keep last 2 months old db + last 4 weeks db + last 7 days db)
#### END        HEADER
#---------------------------------------

#### START      FUNCTIONS DECLARATION
#### END        FUNCTION DECLARATION

#### START      BASIC VARIABLES

LOG_FILE="/var/log/mysql/mysqldump.log"
SDIR="/home/backups/mysql/"
DDIR="/CHANGE_ME/mysql/"
DPRDIR="CHANGE_ME-HOST"
DHOST="root@HOST"

#### END        BASIC VARIABLES
#### START      ARGUMENT PARSING

#### END	ARGUMENT PARSING
#### START      MAIN 

# scp to backup dir
/usr/bin/sshpass -f /PATH_TO_SSHPASS /usr/bin/ssh $DHOST "if [ ! -d $DDIR$DPRDIR ];then mkdir $DDIR$DPRDIR;fi"  || echo "ERROR: while creating a folder ${DDIR}" | tee -a $LOG_FILE

/usr/bin/sshpass -f /PATH_TO_SSHPASS /usr/bin/scp $SDIR/mysqldump_* $DHOST:$DDIR/$DPRDIR/ 2>&1 | tee -a $LOG_FILE 
if [ $? ==  0 ];then echo "OK: ´files copied & verified on remote host" ;else echo "ERROR: copying on remote host";fi  | tee -a $LOG_FILE

#### END	MAIN 
