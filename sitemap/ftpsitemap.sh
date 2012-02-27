#!/bin/bash 
ftp -n<<!
open 58.68.226.231
user netrayli 2008(rayli)index1*0725
binary  
lcd /data/www/html/
prompt 
mget sitemap*

cd 0009/
lcd /data/www/html/0009/ 
mget sitemap*

cd ../0010/
lcd /data/www/html/0010/ 
mget sitemap*

cd ../beauty/
lcd /data/www/html/beauty/ 
mget sitemap*

cd ../0068/
lcd /data/www/html/0068/ 
mget sitemap*

cd ../deco/
lcd /data/www/html/deco/ 
mget sitemap*

cd ../0006/
lcd /data/www/html/0006/ 
mget sitemap*

cd ../fashion/
lcd /data/www/html/fashion/ 
mget sitemap*

cd ../0P10/
lcd /data/www/html/0P10/ 
mget sitemap*

close 
bye 
!
