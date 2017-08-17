#!/bin/bash
# vim: sw=2 ts=2 et fdm=marker

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

####
## Script to run paralel ssh screen channels
## STANDARD - no trancoding
##  ssh crowbar "grep ".8[0-9]" /etc/bind/db.virtual.cloud.suse.de"
####
# set -x

####  change cloud- to cloud2
####  change port 111 to 121
####  change screen name ssh na ssh_host2
####


# function to cleanup old screens + orphans and initiate  new screen
function cleanup()

{
	for i in `screen -ls | awk '$1 ~ /ssh_${cloudhost}/{print $1}'`; do
		screen -S "$i" -X quit
		sleep 2
	done
	screen -AdmS sshdoener4
	sleep 2
}

# function to assign control + compute node variables
function  set_nodes_variables()
{
	[ $withha -eq 1 ]  && controlnodes=2 && nodestartport=13
	if ! [ -z $nodes ]; then
		# 1 is admin
		computenodes=$(( $nodes - $controlnodes - 1 ))
	fi

}

# function to show usage in case of wrong option
function show_usage ()

{

	echo -e "\e[31mParameter did not recognized.\e[0m \n"\
		"\e[1mINFO:\e[0m Script uses ~/.ssh/config and needs to have predefined hosts like:\n"\
		"\e[1mcloud-host cloud-admin-node cloud-controler-nodes cloud-compute-nodes\e[0m\n"\
		"E.g.: \n"\
		"\e[32mHost cloud-admin-node\n"\
		"\e[32mport 11110\n"\
		"\e[32mhostname localhost\n"\
		"\e[32muser root\n"\
		"\e[32mUserKnownHostsFile /dev/null\n"\
		"\e[32mStrictHostKeyChecking no\e[0m\n\n"\
		"Basic usage: $0 -doener[0-9] \n\n"\
		"Mandatory arguments:"\
		"$0 \e[1m-doener[0-9]\e[0m	sets which cloud-host variable will be used\n\n"\
		"Optional arguemnts: (can be mixed together (-ips prints out ips only and exit))\n\n"\
		"$0 \e[1m-set\e[0m	sets cloud-host in ~/.ssh/config and \n\n"\
		"$0 \e[1m-ips\e[0m		show nodes + ip addresses\n"\
		"$0 \e[1m-ha\e[0m		counts with multiple controlers\n"\
		"$0 \e[1m-[0-9]\e[0m	sets number of nodes with admin(can be obtain from -ips option)\n"\
		"Default variables:\n"\
		"without ha, nodenumner 5, controlernodes 1, computenodes 3\n"\
		"ports for ssh connect on localhost starts at \e[1m11110\e[0m\n\n"\
		"Example: Set cloud-host  in ssh and use 5 nodes\n"\
		"	  \"$0 -doener2 -set -5 \"\n"\
		"Example: Use ha and 7 nodes\n"\
		"	  \"$0 -doener2 -ha -7\"\n"
}

# function set cloud-host to desired one in ~/.ssh/config
function set_cloud_host ()
{
	[ -z $cloudhost ] && echo "no cloud host provided";exit 1
# this can be used when multiple clouds can be run
#	sed -i "/cloud$clhostnumber-host/{n;d}" ~/.ssh/config
	sed -i "/Host cloud-host/{n;d;}" ~/.ssh/config
	# add line with port
# this can be used when multiple clouds can be run
#	sed -i "/cloud${clhostnumber}-host/a'\t'hostname ${cloudhost}.${cloudhostdomain}" ~/.ssh/config
	sed -i "/Host cloud-host/a'\t'hostname ${cloudhost}.${cloudhostdomain}" ~/.ssh/config
	# cleanup '
	sed -i "s/'//" ~/.ssh/config
	sed -i "s/'//" ~/.ssh/config

}

# function declaration
function get_ips()
{
	local cloud_host=$1
	local ssh_params="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=No"
	local ssh_command="\"grep \"d52-54.*124.8[0-9]\" /etc/bind/db.virtual.cloud.suse.de\""
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
	lports=(["cloud-admin-node"]+="11110")
	rip=(["cloud-admin-node"]+="192.168.124.10")

	local ssh_params="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=No"
	local ssh_check_ha_command="\"grep \"cluster\" /etc/bind/db.virtual.cloud.suse.de\""
	local ssh_command="\"grep \"d52-54.*124.8[0-9]\" /etc/bind/db.virtual.cloud.suse.de\""
	local node_ips=$(ssh root@${cloud_host} "ssh ${ssh_params} crowbar ${ssh_command}")
	local ssh_check_ha=$(ssh root@${cloud_host} "ssh ${ssh_params} crowbar ${ssh_check_ha_command}")
	if [ $? -ne "0" ]; then echo -e "\nssh failed\n"; exit 1;fi
	[ "$withha" -eq 1 ] && [ "${#ssh_check_ha}" -eq 0 ] && echo "CLOUD HAS NO HA - run without -ha" && exit 1
	[ "$withha" -eq 0 ] && [ "${#ssh_check_ha}" -gt 0 ] && echo "CLOUD HAS HA - run with -ha" && exit 1

	while read -r line; do
		local_nodes=${line%% *}
		local_ip=${line##* }
		if (( "$celement" <= "$controlnodes" )); then
			lports["cloud-control-node${celement}"]+="1111${celement}"
			rip["cloud-control-node${celement}"]+="${local_ip}"
			celement=$((celement + 1))
#			echo ${lports[*]}
		elif (( "$element" <= "$computenodes" ));then
			lports["cloud-compute-node${element}"]+="111${nodestartport}"
			rip["cloud-compute-node${element}"]+="${local_ip}"
			element=$((element + 1))
			nodestartport=$((nodestartport + 1))
#			echo ${lports[*]}
		else
			echo -e "\nMORE Node records found on the server. " \
				 "Run $0 --ips. Maybe increase node number" \
				 " ADMIN is not listed :).\n"
			exit 1
		fi
	done <<< "$node_ips"

}




# vars
declare -A lports
declare -a lports_ips
declare -a lports_nodes
declare -A rip
#[ -z $computenodes ] && computenodes=3
computenodes=${computenodes:=3}
withha=${withha:=0}
tabs=0
controlnodes=${controlnodes:=1}
nodestartport=${nodestartport:=12}
cloudhostdomain=""


# argument handling
for a in $@; do
arg=$a
case "$arg" in
	"")
		;;
	-doener[0-9])
		cloudhost=${arg##-}
		mand_arg_set=1
		shift
		;;
	-ips)
		get_ips cloud-host
		shift
		exit 0
		;;
	-ha)
		withha=1
		shift
		;;
	-[0-9]*)
		nodes=${arg#-*}
		[ $nodes -le 4 ] && exit 1
		shift
		;;
	-set)
		set_cloud_host
		;;
	*)
		show_usage
		exit 0
		;;
esac
done
[ -z $mand_arg_set ]  && echo "cloud host not set, please use -doenerX parameter";exit 1

# main
cleanup
set_nodes_variables
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
echo $i
portnumber="${lports[$i]}"
ipnumber="${rip[$i]}"

# TODO: sed commands need to be cleaned
# delete line
#sed -i "/$i/{n;d}" ~/.ssh/config
sed -i "/port $portnumber/d" ~/.ssh/config
# add line with port
sed -i "/$i/a'\t'port $portnumber" ~/.ssh/config
# cleanup '
sed -i "s/'//" ~/.ssh/config
sed -i "s/'//" ~/.ssh/config
done

# open a session
for i in ${!lports[@]}; do
	portnumber="${lports[$i]}"
	ipnumber="${rip[$i]}"
	screen -S ssh_$cloudhost -X screen -t tab$tabs ssh -Nn cloud-host -l root -L $portnumber:$ipnumber:22

	# increase tab
	tabs=$((tabs+1))
done

