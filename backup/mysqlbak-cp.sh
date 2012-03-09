#! /bin/bash

# MySQL Database DIR: /data/mysql-slave2
# Backup Destination DIR: /backup/mysql-slave2

#Stop the MySQL database
/etc/rc.d/init.d/mysqld stop
sleep 5

#Copy MySQL database data file
/usr/bin/rsync -ar /data/mysql /data/opt/

#Start the MySQL database
/etc/rc.d/init.d/mysqld start

#Compress  MySQL database data file
/bin/tar czf /data/backup/mysql/mysql-credit-`date +%Y%m%d`.tar.gz /data/opt/mysql && rm -rf /data/opt/mysql

#Delete the file rather than from 6 days ago
/usr/bin/find /data/backup/mysql -name "mysql-credit-*.tar.gz" -mtime +6 -exec rm -rf {} \;