#!/bin/bash
start_virtuals () {
	virsh start $1; if [ $1 = "node1" ] || [ $1 = "node2" ] || [ $1 = "admin" ]; \
	then echo "sleeping... 20" && \
	sleep 20; else echo "sleeping... 5" && sleep 5;fi

}

stop_virtuals () {
	virsh shutdown $1; if [ $1 = "node1" ] || [ $1 = "node2" ] || [ $1 = "admin" ]; \
	then echo "sleeping... 20" && \
	sleep 20; else echo "sleeping... 5" && sleep 5;fi

}

destroy_virtuals () {
	virsh destroy $1
}

create_lvm () {
	lvcreate -L 10G -s -n backup_${1} /dev/cloud/${1}
}

remove_lvm () {
	lvremove -f /dev/cloud/backup_${1}
}

merge_lvm () {
	lvconvert --merge /dev/cloud/backup_${1}
}

clear_dmsetup () {
	dmsetup remove /dev/drbd/postgresql && dmsetup remove /dev/drbd/rabbitmq 
}

case $1 in
	create)
		echo "create"
		clear_dmsetup
		ACTION=create_lvm
	;;
	remove)
		echo "remove"
		clear_dmsetup
		ACTION=remove_lvm
	;;
	merge)
		echo "merge"
		clear_dmsetup
		ACTION=merge_lvm
	;;
	start)
		MANAGEMENT=True
		ACTION_MANA=start_virtuals
	;;
	stop)
		MANAGEMENT=True
		ACTION_MANA=stop_virtuals 
	;;
	destroy)
		MANAGEMENT=True
		ACTION_MANA=destroy_virtuals 
	;;
	*)
		echo -e "accepted parameters are: \n"\
			"LVM: $0 create|remove|merge\n"\
			"virsh: $0 start|stop|destroy"
		exit 1
	;;
esac
	

NODES=`virsh list --all --name| grep ^cloud-`
NODES_LVM=`echo ${NODES}| tr "-" "."`
echo $NODES
for a in $NODES_LVM; do CEPHNODES+="${a}-ceph1 ";done
if [ $MANAGEMENT ]; then
	for i in $NODES; do
		$ACTION_MANA $i
	done
else
	for i in $NODES_LVM $CEPHNODES cloud.node1-drbd cloud.node2-drbd; do
		$ACTION $i
	done
fi
