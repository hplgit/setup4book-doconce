#!/bin/bash -x
# Script for compiling a single chapter as an individual document.
# Note that latex refs to other chapters do not work if the other
# chapters are not compiled. Therefore all chapters must be
# compiled twice. (And generalized doconce refs must be used: ref[][][].)

name=$1
shift
args="$@"

# Individual chapter documents will have
# "In this ${BOOK} or ${CHAPTER}" -> "In this document or document"
CHAPTER=document
BOOK=document

function system {
  "$@"
  if [ $? -ne 0 ]; then
    echo "make.sh: unsuccessful command $@"
    echo "abort!"
    exit 1
  fi
}

rm -fr tmp_*

system doconce spellcheck -d .dict4spell.txt *.do.txt

preprocess -DFORMAT=pdflatex ../newcommands.p.tex > newcommands_keep.tex
cp ../.ptex2tex.cfg .

system doconce format pdflatex $name CHAPTER=$CHAPTER BOOK=$BOOK APPENDIX=$APPENDIX --device=paper --latex_admon_color=1,1,1 --latex_admon=mdfbox $args --latex_list_of_exercises=toc --latex_table_format=left -DNOTOC

system ptex2tex $name

# Fixes
doconce replace 'George E. P. Box' 'George E.~P.~Box' $name.tex
doconce replace 'linecolor=black,' 'linecolor=darkblue,' $name.tex
doconce subst 'frametitlebackgroundcolor=.*?,' 'frametitlebackgroundcolor=blue!5,' $name.tex

rm -rf $name.aux $name.ind $name.idx $name.bbl $name.toc $name.loe
system pdflatex $name
bibtex $name
makeindex $name
system pdflatex $name
system pdflatex $name
