
echo "starting script"
for filepath in ./source/images/content/originals_to_resize/*; do
  echo "working with $filepath"
  filename=$(basename $filepath)
  echo "filename $filename"
  gm convert -resize 800x800 $filepath source/images/content/large/$filename
  gm convert -resize 300x300 $filepath source/images/content/small/$filename
  mv $filepath source/images/content/originals/$filename
done
