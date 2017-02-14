#!/bin/bash
# vim: sw=2 ts=2 et fdm=marker
####
## Script to run paralel ssh screen channels
## STANDARD - no trancoding

## to get IP addresses
## run command with "-ip"
##  ssh crowbar "grep ".8[0-9]" /etc/bind/db.virtual.cloud.suse.de"
####
set -x



# function declaration
get_ips()
{
	local cloud_host=$1
	local ssh_params="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=No"
	local ssh_command="\"grep \"124.8[0-9]\" /etc/bind/db.virtual.cloud.suse.de\""
	local node_ips=$(ssh root@${cloud_host} "ssh ${ssh_params} crowbar ${ssh_command}")
	if [ $? -ne "0" ]; then echo -e "\nssh failed\n"; exit 1;fi
	while read -r line; do
		 echo $line | awk '{print $1 " " $4}'
	done <<< "$node_ips"
}

function set_node_names()
{
	local cloud_host=$1
	local celement=1
	local element=1
	local nodestartport=12
	local controlnodes=${controlnodes:=1}
	local computenodes=4
	[ $withha -eq 1 ]  && controlnodes=2 && nodestartport=13
	lports=(["cloud-admin-node"]+="11110")
	rip=(["cloud-admin-node"]+="192.168.124.10")

	local ssh_params="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=No"
	local ssh_command="\"grep \"124.8[0-9]\" /etc/bind/db.virtual.cloud.suse.de\""
	local node_ips=$(ssh root@${cloud_host} "ssh ${ssh_params} crowbar ${ssh_command}")
	if [ $? -ne "0" ]; then echo -e "\nssh failed\n"; exit 1;fi
	[ "$withha" -eq 1 ] && [ "${#node_ips}" -le 194 ] && echo "CLOUD HAS NO HA - run without -ha" && exit 1
	[ "$withha" -eq 0 ] && [ "${#node_ips}" -gt 194 ] && echo "CLOUD HAS HA - run with -ha" && exit 1

	while read -r line; do
		local_nodes=${line%% *}
		local_ip=${line##* }
		if (( "$celement" <= "$controlnodes" )); then
			lports["cloud-controler${celement}-node"]+="1111${celement}"
			rip["cloud-controler${celement}-node"]+="${local_ip}"
			celement=$((celement + 1))
#			echo ${lports[*]}
		elif (( "$element" <= "$computenodes" ));then
			lports["cloud-compute${element}-node"]+="111${nodestartport}"
			rip["cloud-compute${element}-node"]+="${local_ip}"
			element=$((element + 1))
			nodestartport=$((nodestartport + 1))
#			echo ${lports[*]}
		else
			echo "NOTHING FOUND"
		fi
	done <<< "$node_ips"


#	for (( celement = 1; celement <= ${controlnodes}; celement++ ));do
#		echo ${!lports[@]}
#	done
#
#	
#
#
#	for (( element = 1; element <= ${computenodes}; element++ ));do
#
#		#lports=(${lports} ["cloud-compute${element}-node"]="${nodestartport}")
#
##	rip=(["cloud-admin-node"]="10")
#
#	for cislo in ${lports_ips[@]}; do
#		local i=0
#		local nodes=${!lports[@]}
#		echo "$node$cislo"
#		i=$(($i + 1))
#	done
}



# clean and initiate screen
screen -X -S ssh quit
screen -AdmS ssh
sleep 2

# vars
declare -A lports
declare -a lports_ips
declare -a lports_nodes
declare -A rip
withha=0
tabs=0


# argument handling
arg=$1
case "$arg" in
	-ips)
		get_ips cloud-host
		shift
		exit 0
		;;
	-ha)
		withha=1
		;;
esac


set_node_names cloud-host

#echo ${lports[*]}
#echo
#echo ${!lports[*]}
#echo
#echo ${rip[*]}
#echo
#echo ${!rip[*]}

# channels
for i in ${!lports[@]}; do
portnumber="${lports[$i]}"
ipnumber="${rip[$i]}"

# TODO: sed commands need to be cleaned
# delete line
sed -i "/$i/{n;d}" ~/.ssh/config
# add line with port
sed -i "/$i/a'\t'port $portnumber" ~/.ssh/config
# cleanup '
sed -i "s/'//" ~/.ssh/config
sed -i "s/'//" ~/.ssh/config
echo $i
done

# open a session
for i in ${!lports[@]}; do
portnumber="${lports[$i]}"
ipnumber="${rip[$i]}"
screen -S ssh -X screen -t tab$tabs ssh -Nn cloud-host -l root -L $portnumber:$ipnumber:22

# increase tab
tabs=$((tabs+1))
done

##
# cloud-compute-node9
#screen -S ssh -X screen -t tab6 ssh -Nn cloud-host -l root -L 11116:192.168.124.85:22
