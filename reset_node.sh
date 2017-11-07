#!/bin/bash
new_node_name=$1
. ./auto.cnf

function reset_node
{
port=$1
node_name=$2
v_port=$3
primary_flag=$4

single_primary_mode=`cat init.lst|sed -n '2p'|awk '{print $4}'`
if [ ${single_primary_mode} = 'Y' ];
then

 ### Reset MGR In Single Primary Mode
single_primary_mode=`cat init.lst|head -1|grep -w ${port}`
 if [[ -z ${single_primary_mode} ]];
then
 single_primary_mode='N'
else
 single_primary_mode='Y'
fi

echo 'reset node '${node_name}
 if [ ${primary_flag} = 'Y' -a ${single_primary_mode} = 'Y' ];
then
 ${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock -e "
 STOP GROUP_REPLICATION;
 SET GLOBAL group_replication_single_primary_mode=off;
 SET GLOBAL group_replication_enforce_update_everywhere_checks=ON;
 SET GLOBAL group_replication_bootstrap_group=ON;
 START GROUP_REPLICATION;
 SET GLOBAL group_replication_bootstrap_group=OFF;
"
elif [ ${primary_flag} = 'Y' -a ${single_primary_mode} = 'N'  ];then
 ${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock -e   "
 STOP GROUP_REPLICATION;
 SET GLOBAL group_replication_single_primary_mode=off;
 SET GLOBAL group_replication_enforce_update_everywhere_checks=ON;
 START GROUP_REPLICATION;
"
 fi
elif [ ${single_primary_mode} = 'N' ];
then
echo 'reset node '${node_name}
 if [ ${primary_flag} = 'Y' -a ${single_primary_mode} = 'N' ];
then
 ${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock -e "
 STOP GROUP_REPLICATION;
 SET GLOBAL group_replication_single_primary_mode=on; 
 SET GLOBAL group_replication_enforce_update_everywhere_checks=OFF; 
 SET GLOBAL group_replication_bootstrap_group=ON;
 START GROUP_REPLICATION;
 SET GLOBAL group_replication_bootstrap_group=OFF;
"
elif [ ${primary_flag} = 'N' -a ${single_primary_mode} = 'N'  ];then
 ${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock -e   "
 STOP GROUP_REPLICATION;
 SET GLOBAL group_replication_single_primary_mode=on;
 SET GLOBAL group_replication_enforce_update_everywhere_checks=OFF;
 START GROUP_REPLICATION;
"
 fi

fi
}


node_info=`cat init.lst|grep -w ${new_node_name}`
reset_node $node_info
