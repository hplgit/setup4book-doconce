#!/bin/sh
name=$1
cp -r template $name
cd $name
mv NAME.do.txt $name.do.txt
mv main_NAME.do.txt main_$name.do.txt
doconce replace NAME $name main_$name.do.txt make.sh
doconce replace NAME $name make.sh
echo "Customize chapter heading, authors, etc. in $name/main_$name.do.txt"
rm *~
# Nice to have/indicate
mkdir slides-$name fig-$name $src-name
