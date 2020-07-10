#!/bin/sh

#
# Iconizer shell script by Steve Richey (srichey@floatlearning.com)
#
# This is a simple tool to generate all necessary app icon sizes and the JSON file for an *EXISTING* Xcode project from one file.
# To use: specify the path to your vector graphic (PDF format) and the path to your Xcode folder containing Images.xcassets
# Example: sh iconizer.sh MyVectorGraphic.pdf MyXcodeProject
#
# Requires ImageMagick: http://www.imagemagick.org/

if [ $# -ne 1 ]
  then
        echo "\nUsage: sh iconizer.sh file.pdf FolderName\n"
elif [ ! -e "$1" ]
    then
        echo "Did not find file $1, expected path to a vector image file.\n"
elif [ ${1: -4} != ".pdf" ]
    then
        echo "File $1 is not a vector image file! Expected PDF file.\n"
else
    echo "Creating icons from $1 into $2/Images.xcassets/AppIcon.appiconset/..."
    for i in 16 29 32 40 50 57 58 64 72 76 80 87 100 114 120 128 144 152 180 256 512 1024
        do
            echo "Creating $i px icon"
            # convert -density 400 $1 -scale $ix$i ./appicon_$i.png
            convert -density 400 $1 -scale $ix$i -background white -alpha remove -alpha off ./appicon_$i.png 
    done
    echo "Created app icon files, writing Contents.json file..." 
    echo "Complete!"
fi
