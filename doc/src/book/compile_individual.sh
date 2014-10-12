chapters="intuition"
for dir in $chapters; do
  dest=../chapters/$dir
  if [ -d $dest ]; then
    cd $dest
    rm -f tmp*
    bash make.sh
    if [ $? -ne 0 ]; then
      echo "$dest did not compile"
      exit 1
    fi
    cd ../../book
  fi
done
