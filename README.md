# mysql_mgr_test
use script to create MySQL Group Replication environments fast and efficiently.

1. download MySQL installation packages. www.mysql.com and ensure IP is configured is /etc/hosts.    
for example, /etc/hosts as below, 10.127.1.18 is current machine IP, and mysqltestdb is hostname,else MGR creation will have issues.   
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4   
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6   
10.127.1.18  mysqltestdb   

2. change parameters from file auto.cnf following your environment needs.   
for example, change below parameter values, you need to put mysql running path to /usr/local/mysql and create directory /home/data
these can be changed following your needs.   

   base_dir=/usr/local/mysql   
   base_data_dir=/home/data   

3. config file init.lst following your environments needs.   
for example ,I need to crate 5 nodes in one machine, I should config init.lst as below.   
   24801 s1  24901 Y   
   24802 s2  24902 Y    
   24803 s3  24903 Y    
   24804 s4  24904 Y   
   24805 s5  24905 Y 

4. run script init.sh to start MGR environments creation.    

   if you need to create single Primary environments, you should put seconds onwards rows, the last values as N,for example.    
   24801 s1  24901 Y   
   24802 s2  24902 N    
   24803 s3  24903 N     
   24804 s4  24904 N      
   24805 s5  24905 N   
   if you need to create multi-Primary environments, you should put node role as Y, for example.      
   24801 s1  24901 Y   
   24802 s2  24902 Y    
   24803 s3  24903 Y    
   24804 s4  24904 Y   
   24805 s5  24905 Y    

5. use check.sh to check node status, you should use input parameter node_name which is included in init.lst
for example, we want to check node status ,node name is s2 which is from init.lst   
I should use below command to check   
   sh check_node.sh s2   

6. enjoy and feedback if you have more questions, mail to jeanrock@126.com   
