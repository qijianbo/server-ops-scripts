MYSQLSLOW=slow.log.120105
MYSQLSLOW_WORK=slow.log.120105_work.log
cp -f $MYSQLSLOW $MYSQLSLOW_WORK
for((i=101;i<=105;i++)); do
split_date=120$i
echo $split_date
let "next_date=$split_date+1"
#echo $next_date
grep -n -m 1 "Time: $next_date " $MYSQLSLOW_WORK
if [ $? -eq 0 ]
then
#found
cut_line=`grep -n -m 1 "Time: $next_date " $MYSQLSLOW_WORK | awk -F: '{print $1-1}'`
#echo $cut_line
max_line=`wc $MYSQLSLOW_WORK | awk '{print $1}'`
let "rest_line=$max_line-cut_line"
head -n $cut_line  $MYSQLSLOW_WORK > mysqlslow_$split_date.log
tail -n $rest_line $MYSQLSLOW_WORK > t.log
cp -f t.log $MYSQLSLOW_WORK

echo $rest_line
fi

done 
