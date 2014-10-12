#!/bin/sh -x
set -x
chapters="intuition"
for dir in $chapters; do
  dest=../chapters/$dir
  if [ -d $dest ]; then
    ln -s ../chapters/$dir/src-${dir} src-${dir}
    ln -s ../chapters/$dir/fig-${dir} fig-${dir}
  fi
done

# Manual additions:
#ln -s ../chapters/tech/fig-accesspy  fig-accesspy
#ln -s ../chapters/tech/src-varargs   src-varargs
#ln -s ../chapters/tech/src-nose      src-nose
