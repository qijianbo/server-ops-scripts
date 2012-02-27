#!/bin/sh 
logins=`who |wc -l` 
if [ $logins  -le $1 ] 
   then 
   echo "OK!-login count is $logins" 
   exit 0 
fi 
 
if [ $logins -gt $1 -a $logins -le $2 ] 
   then 
   echo "Warnning!-login count is $logins" 
   exit 1 
fi
 
if [ $logins -gt $2 ] 
   then 
   echo  "Critical!-login count is $logins" 
   exit 2 
fi