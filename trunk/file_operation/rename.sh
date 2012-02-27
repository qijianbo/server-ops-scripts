for img in `find . -depth -name "200612*.jpg_small.jpg"` ;
do
txt=`echo $img | sed "s/.jpg_small.jpg/_small.jpg/"`
mv $img $txt
done
