#!/bin/sh
name=erratalist4th

# Compile
doconce format pdflatex $name
doconce ptex2tex $name
pdflatex $name

doconce format html $name --html_style=bloodish

# Publish
cp $name.pdf $name.html ~/vc/scipro-primer
