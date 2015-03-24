#!/bin/sh
# Visit each individual chapter in the book and spellcheck it

chapters="flow rules preface"
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
