#!/bin/bash
####
## Script to run paralel ssh screen channels
## STANDARD - no trancoding

## to get IP addresses
## run command with "-ip"
##  ssh crowbar "grep ".8[0-9]" /etc/bind/db.virtual.cloud.suse.de"
####
#set -x



# function declaration
get_ips()
{
	local cloud_host=$1
	local ssh_params="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=No"
#-o BatchMode=Yes"
	local ssh_command="\"grep \"124.8[0-9]\" /etc/bind/db.virtual.cloud.suse.de\""
	local node_ips=$(ssh root@${cloud_host} "ssh ${ssh_params} crowbar ${ssh_command}")
	if [ $? -ne "0" ]; then echo -e "\nssh failed\n"; exit 1;fi
	while read -r line; do
		 echo $line | awk '{print $1 " " $4}'
	done <<< "$node_ips"
}

# get IPs for nodes only
if ! [ -z $1 ];then
	if [ $1 == "-ip" ]; then get_ips cloud-host;exit 0;fi
fi

# clean and initiate screen
screen -X -S ssh quit
screen -AdmS ssh
sleep 2

# vars
declare -A lports
declare -A rip
tabs=0



lports=(["cloud-admin-node"]="11110"\
	["cloud-control-node1"]="11111"\
	["cloud-control-node2"]="11115"\
	["cloud-compute-node1"]="11112"\
	["cloud-compute-node2"]="11113"\
	["cloud-compute-node3"]="11114"\
)
rip=(["cloud-admin-node"]="10"\
	["cloud-control-node1"]="81"\
	["cloud-control-node2"]="82"\
	["cloud-compute-node1"]="83"\
	["cloud-compute-node2"]="84"\
	["cloud-compute-node3"]="82"\
)
nodes="cloud-admin-node cloud-control-node1 cloud-compute-node1 cloud-compute-node2 cloud-compute-node3"
# HA
#nodes="cloud-admin-node cloud-control-node1 cloud-control-node2 cloud-compute-node1 cloud-compute-node2 cloud-compute-node3"

# channels
for i in $nodes; do
portnumber="${lports[$i]}"
ipnumber="${rip[$i]}"

## TODO: sed commands need to be cleaned
# delete line
sed -i "/$i/{n;d}" ~/.ssh/config
# add line with port
sed -i "/$i/a'\t'port $portnumber" ~/.ssh/config
# cleanup '
sed -i "s/'//" ~/.ssh/config
sed -i "s/'//" ~/.ssh/config

done

# open a session
for i in $nodes; do
portnumber="${lports[$i]}"
ipnumber="${rip[$i]}"
screen -S ssh -X screen -t tab$tabs ssh -Nn cloud-host -l root -L $portnumber:192.168.124.$ipnumber:22

# increase tab
tabs=$((tabs+1))
done

##
# cloud-compute-node9
#screen -S ssh -X screen -t tab6 ssh -Nn cloud-host -l root -L 11116:192.168.124.85:22
