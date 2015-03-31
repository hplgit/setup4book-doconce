#!/bin/sh
name=fake
bash -x make.sh
bash -x ../make_html.sh main_$name
