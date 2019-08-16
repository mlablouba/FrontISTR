#!/bin/bash
mkdir -p manuals/
rm -rf manuals/*

echo "create manual ja"
cd ./FrontISTR_manuals/markdown_files/ja/
mkdocs build --clean
mv site ../../../manuals/manual_ja/
cd -

echo "create manual en"
cd ./FrontISTR_manuals/markdown_files/en/
mkdocs build --clean
mv site ../../../manuals/manual_en/
cd -
