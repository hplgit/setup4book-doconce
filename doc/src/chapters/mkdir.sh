#!/bin/sh
name=$1
cp -r template $name
cd $name
mv main_NAME.do.txt main_$name.do.txt
doconce replace NAME $name main_$name.do.txt
doconce replace NAME $name make.sh
echo "Customize chapter heading, authors, etc. in $name/main_$name.do.txt"

