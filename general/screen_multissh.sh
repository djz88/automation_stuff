#!/bin/bash
####
## Script to run paralel ssh screen channels
## STANDARD - no trancoding
####
set -x

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
	["cloud-compute-node1"]="11112"\
	["cloud-compute-node2"]="11113"\
	["cloud-compute-node3"]="11114"\
)
rip=(["cloud-admin-node"]="10"\
	["cloud-control-node1"]="83"\
	["cloud-compute-node1"]="84"\
	["cloud-compute-node2"]="81"\
	["cloud-compute-node3"]="82"\
)
nodes="cloud-admin-node cloud-control-node1 cloud-compute-node1 cloud-compute-node2 cloud-compute-node3"

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
