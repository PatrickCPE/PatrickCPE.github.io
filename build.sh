#!/bin/sh
emacs -Q --script build-site.el
cp assets build/ -r
cp src/robots.txt build/
