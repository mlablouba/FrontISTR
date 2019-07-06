#!/bin/bash
mkdir -p doc/
rm -rf doc/*

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
