#!/bin/bash
#delete old syslog
MesDate=$(date -d '30 days ago' +%Y-%m-%d)
SqlDate=$(date -d "-1 week" +%m-%d)
Mes=/www/messages

mysql -uroot -p2wsx3edc -e "delete from Syslog.SystemEvents where DATE_FORMAT(DeviceReportedTime,'%m-%d') like '%${SqlDate}%';"
sed -i "/${MesDate}/d" ${Mes}
