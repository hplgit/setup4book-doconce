#!/bin/sh
# Copy src files to scipro-primer to publish the source codes from
# various chapters in the official resource repo for the primer book.
set -x

# Tasks: clean up redundant files, make a new directory tree tmp,
# copy ../chapters/name/src-name to name for all names,
# do special cases, remove special files,
# run rsync_git.py to rsync the tmp tree to scipro-primer and
# add/rm files in git for scipro-primer.

dirname=src
chapters="intuition"
edition=1st

python ~/1/programs/clean.py ../chapters
rm -rf tmp
mkdir tmp
cd tmp
mkdir $dirname
cd $dirname
for chapter in $chapters; do
cp -r ../../../chapters/$chapter/src-$chapter $chapter
done

cp -r ../../../chapters/tech/src-varargs tech
cp -r ../../../chapters/tech/src-nose/* tech/
cp -r ../../../chapters/src-misc misc

# Exclude files
rm -f discalc/*2D*.py
rm -f random/midpt*

cd ..
tar czf book-examples-${edition}.tar.gz src
zip -r book-examples-${edition}.zip src
cp book-examples-${edition}.* ~/vc/scipro-primer/

# Must move to destination
cd ~/vc/scipro-primer
python ~/1/programs/rsync_git.py ~/vc/primer4/doc/src/book/tmp/$dirname src
