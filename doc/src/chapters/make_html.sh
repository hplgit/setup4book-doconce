#!/bin/bash -x
# Compile a chapter as a stand-alone HTML document.
# See make.sh for variables.
#
# Run from subdirectory as
#
# bash -x ../make_html.sh main_chaptername --encoding=utf-8
set -x

mainname=$1
shift
args="$@"

CHAPTER=document
BOOK=document
APPENDIX=document

# mainname: main_chaptername
# nickname: chaptername
nickname=`echo $mainname | sed 's/main_//g'`

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
html=${nickname}-solarized
system doconce format html $mainname $opt --html_style=$style --html_output=$html $args
system doconce split_html $html.html --nav_button=text

style=bootstrap_bluegray
html=${nickname}-bootstrap
system doconce format html $mainname $opt --html_style=$style --html_output=$html $args
system doconce split_html $html.html --nav_button=text

style=bootswatch_readable
html=${nickname}-readable
system doconce format html $mainname $opt --html_style=$style --html_output=$html $args
system doconce split_html $html.html --nav_button=text

# Sphinx themes
themes="basicstrap bloodish pyramid read_the_docs scipy_lectures uio"
themes="uio"
themes="pyramid"

for theme in $themes; do
system doconce format sphinx ${mainname} $opt --sphinx_keep_splits $args
system doconce split_rst ${mainname}
system doconce sphinx_dir theme=$theme dirname=sphinx-$theme ${mainname}
system python automake_sphinx.py
done

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
cp -r ${nickname}-*.html ._${nickname}-*.html $dest/html

for theme in $themes; do
cp -r sphinx-$theme/_build/html $dest/html/sphinx-$theme
done

# index.html for this chapter
cp ../index_html_files.do.txt index.do.txt
system doconce format html index --html_style=bootstrap_FlatUI CHAPTER="${nickname}" --html_bootstrap_navbar=off --html_links_in_new_window $args
cp index.html $dest/html/
rm -f index.*

# We need fig, mov in html publishing dir
rsync="rsync -rtDvz -u -e ssh -b --delete --force "
dirs="fig-$nickname mov-$nickname"
for dir in $dirs; do
  if [ -d $dir ]; then
    $rsync $dir $dest/html
  fi
done

cd $dest
git add html
