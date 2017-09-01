#!/bin/bash
new_node_name=$1
. ./auto.cnf

if [[ -z ${new_node_name} ]]; then
 echo Node Name is needed ~~~
 exit
fi
node_name=`cat init.lst|grep -w ${new_node_name}|awk '{print $2}'`
if [[ ${node_name} = ${new_node_name} ]];then
${base_dir}/bin/mysqld_safe --defaults-file=${base_data_dir}/${node_name}/${node_name}.cnf &
else
 echo Node Name not found in init.lst ~~~ 
fi
