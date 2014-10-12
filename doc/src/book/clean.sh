chapters="intuition"
for dir in $chapters; do
  dest=../chapters/$dir
  if [ -d $dest ]; then
    cd $dest
    sh ../clean.sh
    if [ $? -ne 0 ]; then
      echo "clean.sh did not work"
      exit 1
    fi
    cd ../../book
  fi
done
doconce clean
