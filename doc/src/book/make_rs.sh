#!/bin/sh
set -x
# Experimental RunestoneInteractive book - under development
name=book
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

preprocess -DFORMAT=html ../chapters/newcommands.p.tex > newcommands_keep.tex

opt="CHAPTER=$CHAPTER BOOK=$BOOK APPENDIX=$APPENDIX"

# Compile standard sphinx
system doconce format sphinx $name $opt --sphinx_keep_splits
system doconce split_rst $name
theme=cbc
system doconce sphinx_dir theme=$theme dirname=sphinx-$theme $name
system python automake_sphinx.py

# Generate and compile RunestoneInteractive
system doconce format sphinx $name --runestone $opt --sphinx_keep_splits
system doconce split_rst $name
system doconce sphinx_dir theme=cbc dirname=runestone $name
system python automake_sphinx.py --runestone

# Publish
dest=../../pub
rm -rf $dest/sphinx*
cp -r sphinx-$theme/_build/html $dest/sphinx
cp -r runestone/RunestoneTools/build $dest/sphinx-runestone
cd $dest
git add sphinx-*
