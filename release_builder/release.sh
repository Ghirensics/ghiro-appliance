#!/bin/bash

# Check if output dir exist.
if [ ! -d "output-virtualbox-iso" ]; then
  echo "Missing output-virtualbox-iso folder"
  exit
fi
# Check if release dir exist.
if [ ! -d "release_builder" ]; then
  echo "Missing release_builder folder"
  exit
fi

# Copy readme.
cp release_builder/README.txt output-virtualbox-iso

# Change release
sed -i.bak -e s/X_RELEASE/$1/g output-virtualbox-iso/README.txt
rm output-virtualbox-iso/README.txt.bak

# ZIP
cd output-virtualbox-iso
zip -r -9 output.zip *.ova README.txt
