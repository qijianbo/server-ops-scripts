#!/bin/bash
#mysql backup
#date:2012.02.24
#editor:mayiwei

DATE=`date -d yesterday +%Y-%m-%d`
/usr/local/mysql/bin/mysqldump -uroot -p111111 --default-character-set=utf8 --opt --extended-insert=false --triggers -R --hex-blob -x --all-databases > /data/backup/18.7-db-$DATE.sql
/bin/tar czf /data/backup/18.7-db-$DATE.tar.gz /data/backup/18.7-db-$DATE.sql && rm -rf /data/backup/18.7-db-$DATE.sql
/usr/bin/find /data/backup -name "18.7-db-*.tar.gz" -mtime +6 -exec rm -rf {} \;
