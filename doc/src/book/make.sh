#!/bin/bash -x
# Note: spellcheck should be performed for the individual .do.txt
# files in ../chapters/*
set -x

name=main_book
#name=test
encoding="--encoding=utf-8"

CHAPTER=chapter
BOOK=book

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

# No spellchecking here since main_book.do.txt just includes files.
if [ "$spellcheck" != 'nospell' ]; then
system bash -x spellcheck_individual.sh
fi

preprocess -DFORMAT=pdflatex ../chapters/newcommands.p.tex > newcommands_keep.tex
cp ../chapters/.ptex2tex.cfg .

system doconce format pdflatex $name CHAPTER=$CHAPTER BOOK=$BOOK APPENDIX=$APPENDIX -DNOTOC --device=paper --latex_exercise_numbering=chapter   --latex_style=Springer_T2 --latex_title_layout=titlepage --latex_list_of_exercises=loe --latex_admon=mdfbox --latex_admon_color=1,1,1 --latex_table_format=left --latex_admon_title_no_period --latex_no_program_footnotelink #--latex_index_in_margin

system ptex2tex $name

# Fixes
doconce replace 'George E. P. Box' 'George E.~P.~Box' $name.tex
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

doconce latex_problems main_book.log 10

# Check grammar in MS Word:
# doconce spellcheck tmp_mako__main_book.do.txt
# load tmp_stripped_main_book.do.txt into Word
