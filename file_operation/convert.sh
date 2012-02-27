for img in `find . -depth -name "200612*.jpg"`
do
convert -resize 86x113! "$img" "$img"_small.jpg
done
