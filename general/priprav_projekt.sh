#!/bin/bash
#---------------------------------------
#### START      HEADER
## script for add user to the system and create directory by Zdenek K <n1djz.88@ygg.cz>
## usage ./priprav_projekt.sh username
## debug option
##set -x
## TO DO
## automate more stuff
#### END        HEADER
#---------------------------------------

#### START      FUNCTIONS DECLARATION
#### END        FUNCTION DECLARATION

#### START      BASIC VARIABLES
NEW_UID=$((`tail -1 /etc/passwd | awk -F \: '{print $3}'` + 1));
USER_UID=$NEW_UID;
USERNAME="$1";
HESLO=`apg`
WRONGUSERID="10000"
#### END        BASIC VARIABLES

#### START      ARGUMENT PARSING

# variable validation
if [ -z $1 ];then echo "usage: $0 user";exit 1;fi
if (( NEW_UID < $WRONGUSERID ));then echo "check passwd file, userid is lower than $WRONGUSERID";exit 1;fi

# Sumary of inputs before creating
echo -e "\nSummary: \nuser: \"${USERNAME}\", UID:\"$USER_UID\""
read -p "Is it correct [y/n]? " Y_N
case $Y_N in
	[yY]) ;;
           *) echo "correct inputs..."; exit 1;;
esac
echo
#### END	ARGUMENT PARSING

#### START      MAIN

# creation of user
useradd -d /var/www/html/${USERNAME} --no-create-home --user-group --uid $USER_UID --shell /bin/false --inactive 0 --password '$HESLO' --comment "ftp uzivatel ${USERNAME}" ${USERNAME} && echo "heslo: $HESLO" || echo "ERROR adding user"; exit 1
adduser ${USERNAME} projektyftp || echo "ERROR: adding to group projektyftp"; exit 1
usermod -g projektyftp ${USERNAME}|| echo "ERROR: changing primary group to projektyftp"; exit 1

# creation of a dir
mkdir -p /var/www/html/${USERNAME}/http && chmod -R g+s /var/www/html/${USERNAME} && chown -R ${USERNAME}:projektyftp /var/www/html/${USERNAME} && chmod u-w /var/www/html/${USERNAME} && chmod g+w /var/www/html/${USERNAME}/http


#mysql commands:
#create database $NAME;
#CREATE USER '$NAME'@'localhost' IDENTIFIED BY 'XXXX';
#FLUSH PRIVILEGES;



# have to do actions
echo -e  "Do manually:\n ----------------"
echo "ADD user to vsftp allow user file AND reload configuration"
echo "CP apache site template AND reload configuration"
echo "Create database and add dbname to the mysql-dump file"
echo "set rw rights for apache at folders like tmp or upload"
echo "Add db to mysql-dump in /etc/cron.daily/"
#### END        MAIN

