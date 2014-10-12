# Pack a book project for Springer
set -x

name=unpingco
book=book.tex

# Put all files in directory $name
rm -rf $name
mkdir $name
cd $name
cp ../main_book.tex $book

# Copy all figures to one directory
mkdir figs
for dir in ../fig-*; do
  cp $dir/* figs
done
doconce subst '\{fig-.+?/' '{figs/' $book

# Copy style files
cp ~/texmf/tex/latex/misc/t2do.sty t2_hpl.sty
cp ~/texmf/tex/latex/misc/svmonodo.cls svmono_hpl.cls
doconce replace '{t2do}' '{t2_hpl}' $book
doconce replace '{svmonodo}' '{svmono_hpl}' $book
doconce subst '% Use .+ with doconce modifications.*' '' book.tex

cp ../README_Springer_dir.txt 00README.txt
cp ../../chapters/papers.bib .
doconce replace '{../chapters/papers}' '{papers}' $book

cp ../newcommands_keep.tex .

rm -rf tmp.txt
pdflatex book | tee tmp.txt
rm -rf *.dvi *.aux *.out *.log *.loe *.toc
cp ../main_book.log book_last_run.log
doconce latex_problems book_last_run.log > book_last_run.log.summary

doconce grab --from- '\*File List\*' --to- '\*\*\*\*' tmp.txt > tmp2.txt
python ../grab_stylefiles.py tmp2.txt  # make script tmpcp.sh
mkdir stylefiles
cd stylefiles
sh ../tmpcp.sh
cd ..
rm tmpcp.sh
rm *~ tmp*
cp ../main_book.pdf book.pdf

echo 'Pause before sending tar file to Springer...'
sleep 2
cd ..
user=b3143
passwd=spvb3143
url=213.71.6.142
#--------------------------------------------
file=TCSE6_4th_Mar31.tar.gz
#--------------------------------------------
tar czf $file $name
ftp -n $url <<EOF
quote $user
quote $passwd
cd unpingco
put $file
EOF

# cp to GoogleDrive
# cp unpingco/book.tex $file "/mnt/hgfs/hpl/Google Drive/Springer-TCSE6"
