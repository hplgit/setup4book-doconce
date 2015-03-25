#!/bin/bash
# Make slides for lectures.
#
# ../make_lectures.sh lectures_ch2.do.txt

# The complete doconce filename with .do.txt is the command line argument
# for this script
dofile=$1
if [ ! -f $dofile ]; then
  echo "No such file: $dofile"
  exit 1
fi

# Strip off .do.txt in filename
name=`echo $dofile | sed 's/\.do\.txt//'`

# Safe execution of doconce commands - with abortion if they don't succeed
function system {
  "$@"
  if [ $? -ne 0 ]; then
    echo "make.sh: unsuccessful command $@"
    echo "abort!"
    exit 1
  fi
}

# Spellcheck files first (this is done in subdirectories so updated
# dictionaries are located there!)
dir=`/bin/ls -d lec-*`  # assume only one lec_* dir...
cd $dir
rm -rf tmp*
system doconce spellcheck -d ../.dict4spell.txt *.do.txt
cd ..

# It is wise to first compile a plain LaTeX PDF version of
# the sides/study gude since that will reveal potential syntax errors.
# (HTML gives far less errors and warnings than LaTeX).
rm -f *.aux
preprocess -DFORMAT=pdflatex ../newcommands.p.tex > newcommands_keep.tex

system doconce format pdflatex $name --latex_admon=paragraph "--latex_code_style=default:lst-yellow2@sys:vrb[frame=lines,label=\\fbox{{\tiny Terminal}},framesep=2.5mm,framerule=0.7pt]"
doconce replace 'section{' 'section*{' ${name}.tex

system pdflatex $name
system pdflatex $name
cp -f $name.pdf ${name}-plain.pdf

# HTML versions
preprocess -DFORMAT=html ../newcommands_keep.p.tex > newcommands_keep.tex
opt="-DWITH_TOC"

# reveal.js HTML5 slides
html=${name}-reveal
system doconce format html $name --pygments_html_style=native --keep_pygments_html_bg --html_output=$html $opt
system doconce slides_html ${html}.html reveal --html_slide_theme=darkgray

html=${name}-reveal-beige
system doconce format html $name --pygments_html_style=perldoc --keep_pygments_html_bg --html_output=$html $opt
system doconce slides_html ${html}.html reveal --html_slide_theme=beige

# deck.js HTML5 slides
html=${name}-deck
system doconce format html $name --pygments_html_style=perldoc --keep_pygments_html_bg --html_output=$html $opt
system doconce slides_html ${html}.html deck --html_slide_theme=sandstone.default

# Plain HTML with everything in one file (fine for browsing and turning up the font in the browser)
html=${name}-1
system doconce format html $name --html_style=bloodish --html_output=$html  $opt
doconce replace "<li>" "<p><li>" ${html}.html  # add space around bullets
doconce split_html ${html}.html --method=space8

# HTML with solarized style in one big file
html=${name}-solarized
system doconce format html $name --html_style=solarized3 --html_output=$html --pygments_html_style=perldoc --pygments_html_linenos $opt
doconce replace "<li>" "<p><li>" ${html}.html  # add space around bullets
doconce split_html ${html}.html --method=space8
# Can split plain html slides too into one file per slide...

# Markdown Remark style (for web browser viewing)
doconce format pandoc $name --github_md $opt
doconce slides_markdown $name remark --slide_theme=light
cp $name.html ${name}-remark.html

# LaTeX Beamer slides with plain pygments style for code
rm -f *.aux
preprocess -DFORMAT=pdflatex ../newcommands_keep.p.tex > newcommands_keep.tex

system doconce format pdflatex $name --latex_title_layout=beamer --latex_table_format=footnotesize --latex_admon_title_no_period --latex_code_style=pyg
# Note: no TOC for beamer, that is built in
theme=red_shadow
system doconce slides_beamer $name --beamer_slide_theme=$theme

system pdflatex -shell-escape $name
pdflatex -shell-escape $name
pdflatex -shell-escape $name
cp ${name}.pdf ${name}-beamer.pdf
rm -f ${name}.pdf
cp ${name}.tex ${name}-beamer.tex  # sometimes handy to check

# Handouts
system doconce format pdflatex $name --latex_title_layout=beamer --latex_table_format=footnotesize --latex_admon_title_no_period --latex_code_style=pyg
system doconce slides_beamer $name --beamer_slide_theme=red_shadow --handout

system pdflatex -shell-escape $name
pdflatex -shell-escape $name
pdflatex -shell-escape $name
pdfnup --nup 2x3 --frame true --delta "1cm 1cm" --scale 0.9 --outfile ${name}-beamer-handouts2x3.pdf ${name}.pdf
rm -f ${name}.pdf

# Publish
dest=/some/repo/some/where
dest=../../../pub
if [ ! -d $dest ]; then
exit 0  # drop publishig
fi
dest=$dest/$name
if [ ! -d $dest ]; then
  mkdir $dest
  mkdir $dest/html
  mkdir $dest/pdf
fi
cp -r ${name}-*.html ._${name}-*.html $dest/html
# index.html for this chapter
cd ..
system doconce format html index_html_files --html_style=bootstrap_FlatUI CHAPTER="${name}" --html_bootstrap_navbar=off
cp index_html_files.html $dest/html/index.html
rm -f index_html_files.html
cd -   # back to subdir for chapter
if [ -d fig-$name ]; then
if [ ! -d $dest/$fig-$name ]; then
cp -r fig-$name $dest/html
else
cp -r fig-$name/* $dest/html/fig-$name/
fi
fi
cd $dest
git add html


