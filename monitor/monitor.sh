#!/bin/bash
# monitoring script 
if [ ! -d /var/log/monitor ]; then mkdir /var/log/monitor/;fi 
LOG="/var/log/monitor/monitor_`date +%d-%m`.log"
LLOG="/var/log/monitor/monitor_apache_`date +%d-%m`.log"
echo " ------------------- STARTING ------------------" >> $LOG
echo " ------------------- STARTING ------------------" >> $LLOG
date >> $LOG
date >> $LLOG
echo "-----" >> $LOG
sar 2 2 >> $LOG
echo "-----" >> $LOG
free -m >> $LOG
echo "-----" >> $LOG
echo "netstat:" >> $LOG
netstat -na | grep :80 | wc -l >> $LOG
echo "http uniq connections:" >> $LOG
netstat -na | grep ":80" | sort -nr -k 7 | awk '{ print $5 }'| awk '{ sub("::ffff:",""); print }'| awk -F ":" '{ print $1 }' | uniq | wc -l >> $LOG
echo "-----" >> $LOG
echo "TCP stats:" >> $LOG
netstat -an|awk '/tcp/ {print $6}'|sort|uniq -c >> $LOG
sar -d 2 2 >> $LOG
echo "-----" >> $LOG
sar -n DEV  2 2 >> $LOG
echo "-----" >> $LOG
sar -r 2 2 >> $LOG
echo "-----" >> $LOG
echo "apache count:" >> $LOG
ps awux | grep [a]pache | wc -l >> $LOG
echo "-----" >> $LOG
echo "apache list:" >> $LLOG
ps awux | grep [a]pache >> $LLOG
echo "-----" >> $LLOG
echo "apache average memory:"  >> $LLOG
ps -eo user,%cpu,%mem,rsz,args|sort -rnk4|awk 'BEGIN {printf "%8s\t%6s\t%6s\t%8s\t%s\n","USER","%CPU","%MEM","RSZ","COMMAND"}{printf "%8s\t%6s\t%6s\t%8s MB\t%-12s\n",$1,$2,$3,$4/1024,$5}' | grep apache | awk '{sum+=$4}END{print sum/NR}' >> $LLOG
echo "-----" >> $LLOG
echo "disks:" >> $LOG
iostat -x -d -m 2 4 >> $LOG
iostat -x -d -m -p /dev/vda 2 4 >> $LOG
echo "pid mysql:" >> $LOG
pidstat -C mysql -d 2 4 >> $LOG
echo " ------------------- STOPPING ------------------" >> $LOG
echo " ------------------- STOPPING ------------------" >> $LLOG

