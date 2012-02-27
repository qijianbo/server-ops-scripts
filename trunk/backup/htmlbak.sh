#!/bin/sh
DATE=`date +%y-%m-%d-%H`
cd /data/www/wwwroot
tar cvzf adclick-html$DATE.tar.gz adclick/
mv adclick-html$DATE.tar.gz /data/backup
/usr/bin/find /data/backup -name "adclick-html*.tar.gz" -mtime +6 -exec rm -rf {} \;