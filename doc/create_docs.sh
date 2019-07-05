#!/bin/bash
cd ..; git submodule update -i; cd -
rm -rf doc/*

echo "create developers guide"
doxygen ./Doxyfile.in
mv doc/html doc/function_reference

echo "create manual ja"
cd ./FrontISTR_manuals/markdown_files/ja/
mkdocs build --clean
mv site ../../../doc/manual_ja/
cd -

echo "create manual en"
cd ./FrontISTR_manuals/markdown_files/en/
mkdocs build --clean
mv site ../../../doc/manual_en/
cd -
