#!/bin/bash

#---------------------------------------
#### START      HEADER
## script for mysql databases dump by Zdenek K <n1djz.88@ygg.cz>
## usage ./mysqldump.sh username domain 
## debug option
##set -x
## TO DO
## add different filename for manual dump
#### END        HEADER
#---------------------------------------


#### START      FUNCTIONS DECLARATION

# function dump db
# usage dump_db $MYSQL_DB
dump_db ()
{
	if [ -z $1 ] || [ "$1" != "$MYSQL_DB" ]; then echo "[ERROR] Wrong fucntion call!";exit 1; fi
	if [ $1 = performance_schema ]; then LOCAL_MYSQLDUMP_CMD="$MYSQLDUMP_CMD --skip-lock-tables performance_schema";
	elif [ $1 = mysql ]; then LOCAL_MYSQLDUMP_CMD="$MYSQLDUMP_CMD --ignore-table=mysql.event mysql ";
	elif [ $1 = all ]; then LOCAL_MYSQLDUMP_CMD="$MYSQLDUMP_CMD --ignore-table=mysql.event --all-databases ";
	else LOCAL_MYSQLDUMP_CMD="$MYSQLDUMP_CMD $MYSQL_DB"; fi
	#command
	$LOCAL_MYSQLDUMP_CMD > ${MYSQLDUMP_LOC}/mysqldump_${MYSQL_DB}.sql

	echo
	echo "DB ${MYSQL_DB} dumped to the file on `date`:"
	ls $MYSQLDUMP_LOC/mysqldump_${MYSQL_DB}.sql

return 0
}


# function last backup
# usage lastbck_db $DATABASE
lastdb ()
{
return 0
}


# function restore database
# usage restore_db $DATABASE
restore_db ()
{
	# mysql -uroot -p mysql < mysql.sql
return 0
}


#### END        FUNCTION DECLARATION

# example command
#root@HOST:~# mysqldump --opt --user=root --password=XXXXXXX DATABASE TABLE --where="COLUMN='VALUE'" > test.sql


#### START      BASIC VARIABLES

MYSQL_DB_DEF="all"
MYSQLDUMP_CMD="mysqldump --opt --user=root --password=XXXXXXX --skip-add-locks"
MYSQLDUMP_LOC="/home/backups/mysql"
#### END        BASIC VARIABLES

#### START      ARGUMENT PARSING

if [ -z $1 ]; then echo "usage: \"mysqldump.sh [-b|-m|-r] database)\"";exit;fi
#if [ $# -lt "2" ]; then echo "not enough arguments: \"mysqldump.sh -b database\"";exit;fi

while [[ $# > 0 ]]
do
arg="$1"
shift
case $arg in
        	-b)
		ACTION="dump"
		if [ -z $1 ]; then MYSQL_DB=$MYSQL_DB_DEF;else MYSQL_DB=$1; fi
	        shift
	        ;;
	        -h|--help|*)
		echo -e "--------------\nsee last db backup:		mysqldump.sh -m database\nrun database backup:		mysqldump.sh -b database\nrestore database:		mysqldump.sh -r database\n--------------\n-m database	last backup\n-b database	run backup\n-r		restore database\n-h,--help	help"
		exit 1
		;;
	esac
done
#### END	ARGUMENT PARSING

#### START      MAIN 

# mapping variables for mysql
if [ $ACTION = dump ] && [ -n $MYSQL_DB ]; then dump_db $MYSQL_DB; else echo "[ERROR] No database provided"; exit 1; fi

#### END	MAIN 

exit 0
