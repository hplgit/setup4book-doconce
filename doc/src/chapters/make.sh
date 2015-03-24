#!/bin/bash -x
# Script for compiling a single chapter as an individual document.

# Note that latex refs to other chapters do not work if the other
# chapters are not compiled. Therefore all chapters must first be
# compiled. Then an individual chapter can be compiled.
# Note that generalized doconce refs must be used: ref[][][] if one
# refers to material in a different chapter (only necessary when
# compiling individual chapters, the book will work with standard refs).

name=$1
shift
args="$@"

# Individual chapter documents will have formulations like
# "In this ${BOOK}" or "in this ${CHAPTER}" to be transformed
# to "In this document" when the chapter stands on its own, while
# for a book we want "In this book" and "in this chapter".
CHAPTER=document
BOOK=document
APPENDIX=document

# Function for running operating system commands. The script aborts
# if the execution is unsuccessful. All doconce, latex, etc. commands
# in this script are run with the system function such that the script
# stops when the first error is encountered.
function system {
  "$@"
  if [ $? -ne 0 ]; then
    echo "make.sh: unsuccessful command $@"
    echo "abort!"
    exit 1
  fi
}

rm -fr tmp_*

# Perform spell checking
system doconce spellcheck -d .dict4spell.txt *.do.txt

# Copy common newcommands
preprocess -DFORMAT=pdflatex ../newcommands.p.tex > newcommands_keep.tex
# Copy ptex2tex configuration file if not using the newer --latex_code_style=...
#cp ../.ptex2tex.cfg .

opt="CHAPTER=$CHAPTER BOOK=$BOOK APPENDIX=$APPENDIX"

system doconce format pdflatex $name $opt --device=paper --latex_admon_color=1,1,1 --latex_admon=mdfbox $args --latex_list_of_exercises=toc --latex_table_format=left "--latex_code_style=default:vrb-blue1@sys:vrb[frame=lines,label=\\fbox{{\tiny Terminal}},framesep=2.5mm,framerule=0.7pt]"
# code style: blue boxes with plain verbatim for all code, special
# terminal style for sys

# Auto-editing of .tex file (tailored adjustments)
doconce replace 'linecolor=black,' 'linecolor=darkblue,' $name.tex
doconce subst 'frametitlebackgroundcolor=.*?,' 'frametitlebackgroundcolor=blue!5,' $name.tex

rm -rf $name.aux $name.ind $name.idx $name.bbl $name.toc $name.loe
system pdflatex $name
bibtex $name
makeindex $name
system pdflatex $name
system pdflatex $name
