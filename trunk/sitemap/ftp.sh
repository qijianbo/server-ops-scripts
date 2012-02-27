#!/bin/bash 
ftp -n<<! 
open 125.39.40.251
user rayli-www2 2008(rayli)index2*0725
binary  
lcd /var/www/html
prompt 
mget sitemap*
close 
bye 
!
