# Use a common make.sh file, or do customized building here
# (for this special document, we demonstrate many preprocess commands
# so we need to avoid running preprocess when compiling the document)
bash -x ../make.sh main_rules --encoding=utf-8 --no_preprocess
