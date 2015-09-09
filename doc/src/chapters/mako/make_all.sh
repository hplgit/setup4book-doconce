#!/bin/sh
# Remember --no_mako (include in make.sh)
# PDF
bash make.sh
# HTML
bash ../make_html.sh main_mako --no_mako --no_preprocess
