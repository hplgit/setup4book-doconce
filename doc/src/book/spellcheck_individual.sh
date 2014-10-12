chapters="intuition"
for dir in $chapters; do
  dest=../chapters/$dir
  if [ -d $dest ]; then
    cd $dest
    rm -f tmp*
    doconce spellcheck -d .dict4spell.txt *.do.txt
    if [ $? -ne 0 ]; then
      echo "$dest has spellcheck errors"
      exit 1
    fi
    cd ../../book
  fi
done
