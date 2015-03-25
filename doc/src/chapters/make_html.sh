#!/bin/bash -x
# Compile a chapter as a stand-alone HTML document.
# See make.sh for variables.
#
# Run from subdirectory as
#
# bash -x ../make_html.sh main_chaptername --encoding=utf-8
set -x

name=$1
shift
args="$@"

CHAPTER=document
BOOK=document
APPENDIX=document

# name: main_chaptername
# nickname: chaptername
nickname=`echo $name | sed 's/main_//g'`

function system {
  "$@"
  if [ $? -ne 0 ]; then
    echo "make.sh: unsuccessful command $@"
    echo "abort!"
    exit 1
  fi
}

rm -fr tmp_*

# Spell checking: done in make.sh

preprocess -DFORMAT=html ../newcommands.p.tex > newcommands_keep.tex

opt="CHAPTER=$CHAPTER BOOK=$BOOK APPENDIX=$APPENDIX"

style=solarized3
html=${name}-solarized
system doconce format html $name $opt --html_style=$style --html_output=$html $args
system doconce split_html $html.html --nav_button=text

style=bootstrap_bluegray
html=${name}-bootstrap
system doconce format html $name $opt --html_style=$style --html_output=$html $args
system doconce split_html $html.html --nav_button=text

style=bootswatch_readable
html=${name}-readable
system doconce format html $name $opt --html_style=$style --html_output=$html $args
system doconce split_html $html.html --nav_button=text

# Publish
dest=/some/repo/some/where
dest=../../../pub
if [ ! -d $dest ]; then
exit 0  # drop publishig
fi
dest=$dest/$nickname
if [ ! -d $dest ]; then
  mkdir $dest
  mkdir $dest/pdf
  mkdir $dest/html
fi
cp -r ${name}-*.html ._${name}-*.html $dest/html
# index.html for this chapter
cp ../index_html_files.do.txt index.do.txt
system doconce format html index --html_style=bootstrap_FlatUI CHAPTER="${nickname}" --html_bootstrap_navbar=off --html_links_in_new_window $args
cp index.html $dest/html/
rm -f index.*
if [ -d fig-$nickname ]; then
if [ ! -d $dest/$fig-$nickname ]; then
cp -r fig-$nickname $dest/html
else
cp -r fig-$nickname/* $dest/html/fig-$nickname/
fi
fi
cd $dest
git add html
