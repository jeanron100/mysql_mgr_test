#!/bin/bash
new_node_name=$1
. ./auto.cnf

function reset_node
{
port=$1
node_name=$2
v_port=$3
primary_flag=$4
init_node_flag=`cat init.lst|sed -n '2p'|awk '{print $4}'`
if [ ${init_node_flag} = 'N' ];
then
 exit
fi

init_node_flag=`cat init.lst|head -1|grep -w ${port}`
if [[ -z ${init_node_flag} ]];
then
init_node_flag='N'
else
init_node_flag='Y'
fi
echo 'reset node '${node_name}
if [ ${primary_flag} = 'Y' -a ${init_node_flag} = 'Y' ];
then
${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock -e "
stop GROUP_REPLICATION;
set global group_replication_single_primary_mode=off;
set global group_replication_enforce_update_everywhere_checks=ON;
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
"
elif [ ${primary_flag} = 'Y' -a ${init_node_flag} = 'N'  ];then
${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock -e   "
stop GROUP_REPLICATION;
set global group_replication_single_primary_mode=off;
set global group_replication_enforce_update_everywhere_checks=ON;
start group_replication;
"
fi

}


node_info=`cat init.lst|grep -w ${new_node_name}`
reset_node $node_info
