#!/bin/bash -x
# Compile a chapter as a stand-alone HTML document.
# See make.sh for variables.
#
# Run from subdirectory as
#
# bash -x ../make_html.sh main_chaptername --encoding=utf-8

name=$1
shift
args="$@"

CHAPTER=document
BOOK=document
APPENDIX=document

# wrap: main_chaptername
# name: chaptername
wrap=$name
name=`echo $name | sed 's/main_//g'`

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
system doconce format html $wrap $opt --html_style=$style --html_output=$html
system doconce split_html $html.html --nav_button=text

style=bootstrap_bluegray
html=${name}-bootstrap
system doconce format html $wrap $opt --html_style=$style --html_output=$html
system doconce split_html $html.html --nav_button=text

style=bootswatch_readable
html=${name}-readable
system doconce format html $wrap $opt --html_style=$style --html_output=$html
system doconce split_html $html.html --nav_button=text

# Publish
dest=../../pub  # local dir (gh-pages on github)
dest=/some/repo/for/publishing/html   # external repo
if [ ! -d $dest ]; then
exit 0
fi

if [ ! -d $dest/$name ]; then
  mkdir $dest/$name
fi
cp -r ${name}-*.html ._${name}-*.html $dest/$name
# index.html for this chapter
cd ..
system doconce format html index_html_files --html_style=bootstrap_FlatUI CHAPTER="${name}" --html_bootstrap_navbar=off
cp index_html_files.html $dest/$name/index.html
rm -f index_html_files.html
cd -   # back to subdir for chapter
if [ -d fig-$name ]; then
cp -r fig-$name $dest/$name
fi
cd $dest
git add $name

