#!/bin/bash -x
# Compile the book to LaTeX/PDF.
#
# Usage: make.sh [nospell]
#
# With nospell, spellchecking is skipped.

set -x

name=book
#name=test
encoding="--encoding=utf-8"

CHAPTER=chapter
BOOK=book
APPENDIX=appendix

function system {
  "$@"
  if [ $? -ne 0 ]; then
    echo "make.sh: unsuccessful command $@"
    echo "abort!"
    exit 1
  fi
}

rm tmp_*

if [ $# -ge 1 ]; then
  spellcheck=$1
else
  spellcheck=spell
fi

# No spellchecking of local files here since book.do.txt just includes files.
# Spellcheck all *.do.txt files in each chapter.
if [ "$spellcheck" != 'nospell' ]; then
python -c 'import scripts; scripts.spellcheck()'
fi

preprocess -DFORMAT=pdflatex ../chapters/newcommands.p.tex > newcommands_keep.tex

opt="CHAPTER=$CHAPTER BOOK=$BOOK APPENDIX=$APPENDIX"

system doconce format pdflatex $name $opt --device=paper --latex_exercise_numbering=chapter   --latex_style=Springer_T2 --latex_title_layout=titlepage --latex_list_of_exercises=loe --latex_admon=mdfbox --latex_admon_color=1,1,1 --latex_table_format=left --latex_admon_title_no_period --latex_no_program_footnotelink "--latex_code_style=default:lst[style=blue1]@pypro:lst[style=blue1bar]@dat:lst[style=gray]@sys:vrb[frame=lines,label=\\fbox{{\tiny Terminal}},framesep=2.5mm,framerule=0.7pt]" #--latex_index_in_margin

# Auto edits
doconce replace 'linecolor=black,' 'linecolor=darkblue,' $name.tex
doconce subst 'frametitlebackgroundcolor=.*?,' 'frametitlebackgroundcolor=blue!5,' $name.tex

rm -rf $name.aux $name.ind $name.idx $name.bbl $name.toc $name.loe

system pdflatex $name
system bibtex $name
system makeindex $name
system pdflatex $name
system pdflatex $name
system makeindex $name
system pdflatex $name

# Publish
cp book.pdf ../../pub

# index file for book and all chapters
cd ../chapters
cp index_files.do.txt index.do.txt
system doconce format html index --html_style=bootstrap --html_links_in_new_window --html_bootstrap_navbar=off
cp index.html ../../pub
rm -f index.*
cd -

# Report typical problems with the book (too long lines,
# undefined labels, etc.). Here we report lines that are more than 10pt
# too long.
doconce latex_problems $name.log 10

# Check grammar in MS Word:
# doconce spellcheck tmp_mako__book.do.txt
# load tmp_stripped_book.do.txt into Word
