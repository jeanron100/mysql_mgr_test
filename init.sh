#!/bin/bash  
. ./auto.cnf
base_conf_dir=`pwd`

init_node_flag=`cat init.lst|head -1|awk '{print $4}'`

function get_seed_list
{
while read line
do
tmp_port='127.0.0.1:'`echo $line|awk '{print $3}'`
echo ${tmp_port}
done <init.lst|xargs |sed 's/ /,/g'
}

export seed_list=`get_seed_list`
#echo ${seed_list}

function init_node
{
echo $seed_list
port=$1
node_name=$2
v_port=$3
primary_flag=$4
init_node_flag=`cat init.lst|head -1|grep -w ${port}`
if [[ -z ${init_node_flag} ]];
then
init_node_flag='N'
else
init_node_flag='Y'
fi

echo $init_node_flag
if [ ${primary_flag} = 'Y' -a ${init_node_flag} = 'Y' ];
then
primary_flag='Y'
else
primary_flag='N'
fi

${base_dir}/bin/mysqld --no-defaults --initialize-insecure --basedir=${base_dir} --datadir=${base_data_dir}/${node_name} --explicit_defaults_for_timestamp

chown -R mysql:mysql  ${base_data_dir}/${node_dir}

cp ${base_conf_dir}/s.cnf ${base_data_dir}/${node_name}/${node_name}.cnf
sed -i 's:${base_data_dir}:'"${base_data_dir}:g"'' ${base_data_dir}/${node_name}/${node_name}.cnf
sed -i 's:${base_dir}:'"${base_dir}:g"'' ${base_data_dir}/${node_name}/${node_name}.cnf
sed -i 's:${node_name}:'"${node_name}:g"''  ${base_data_dir}/${node_name}/${node_name}.cnf
sed -i 's:${port}:'"${port}:g"''  ${base_data_dir}/${node_name}/${node_name}.cnf
sed -i 's:${v_port}:'"${v_port}:g"'' ${base_data_dir}/${node_name}/${node_name}.cnf
sed -i 's/${seed_list}/'"${seed_list}/g"'' ${base_data_dir}/${node_name}/${node_name}.cnf

chown -R mysql:mysql ${base_data_dir}/${node_name}

${base_dir}/bin/mysqld_safe --defaults-file=${base_data_dir}/${node_name}/${node_name}.cnf &

sleep  5

${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock  -e "show databases"

if [[ ${primary_flag} = 'Y' ]];then

${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock -e "
SET SQL_LOG_BIN=0;
CREATE USER rpl_user@'%';
GRANT REPLICATION SLAVE ON *.* TO rpl_user@'%' IDENTIFIED BY 'rpl_pass';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='rpl_user', MASTER_PASSWORD='rpl_pass'
                      FOR CHANNEL 'group_replication_recovery';
INSTALL PLUGIN group_replication SONAME 'group_replication.so';               
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
select *from performance_schema.replication_group_members;
"
elif [[ ${primary_flag} = 'N' ]];then

${base_dir}/bin/mysql -P${port}  -S ${base_data_dir}/${node_name}/${node_name}.sock -e   "
SET SQL_LOG_BIN=0;
CREATE USER rpl_user@'%';
GRANT REPLICATION SLAVE ON *.* TO rpl_user@'%' IDENTIFIED BY 'rpl_pass';
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='rpl_user', MASTER_PASSWORD='rpl_pass'
        FOR CHANNEL 'group_replication_recovery';
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
set global group_replication_allow_local_disjoint_gtids_join=on;
start group_replication;
select *from performance_schema.replication_group_members;
"
else
   echo 'Please check variable primary_flag'
fi

}
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
#MAIN

while read line
do
echo ${seed_list}
echo ok
init_node $line
done <init.lst

while read line
do
reset_node $line
done <init.lst
