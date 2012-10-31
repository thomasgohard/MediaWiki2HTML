#!/bin/bash

################################################################################
#
#	MediaWiki2HTML -- A WikiMedia to HTML converter
#
#-------------------------------------------------------------------------------
#
#	Author: @thomasgohard (https://github.com/thomasgohard/)
#	Version: v1.0
#
#-------------------------------------------------------------------------------
#
#	Copyright (c) 2012 Thomas Gohard
#
#	Permission is hereby granted, free of charge, to any person obtaining a
#	copy of this software and associated documentation files (the
#	"Software"), to deal in the Software without restriction, including with
#	out limitation the rights to use, copy, modify, merge, publish,
#	distribute, sublicense, and/or sell copies of the Software, and to
#	permit persons to whom the Software is furnished to do so, subject to
#	the following conditions:
#
#	The above copyright notice and this permission notice shall be included
#	in all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
#	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################

#
# Messages
#
USAGE="USAGE:\n\n$ MediaWiki2HTML [WikiMedia File] [HTML File]\n\nWhere:\n\t[WikiMediaFile] is the path to the WikiMedia file to convert to HTML\n\t[HTML File] is the path where to write the HTML resulting from the conversion."

#
# Settings
#
wrkgext=.wrkg
tmpext=.tmp

#
# Check number of arguments
#
if [ $# -ne 2 ];
then
	echo -e "Error: Incorrect number of arguments.\n";
	echo -e $USAGE;
	exit 1;
fi

#
# Check arguments
#
inputpath=$1
outputpath=$2

if [ ! -f $inputpath ];
then
	echo -e "Error: $inputpath does not exist.\n";
	exit 2;
fi

if [ -f $outputpath ];
then
	echo -e "$outputpath already exists. Overwrite $outputpath? ";
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) rm $outputpath; break;;
			No ) exit 3;;
		esac
	done
fi

#
# Backup Internal Field Separator value and replace it with new line
#
IFS_backup=$IFS;
IFS=$'\n';

#
# Load regular expressions
#
regexpath=./MediaWiki2HTML.regexes
regexes=(`grep "^\s*[^#]" $regexpath`);

#
# Set working filenames
#
wrkgpath=$outputpath$wrkgext;
tmppath=$outputpath$tmpext;
filename=$(basename $inputpath);

if [ -f $wrkgpath ]; then rm $wrkgpath; fi
if [ -f $tmppath ]; then rm $tmppath; fi

#
# Convert [WikiMedia File] to HTML
#
echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\t\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang=\"en\" lang=\"en\">\n<head>\n\t<title>${filename%.*}</title>\n</head>\n<body>" >> $wrkgpath;
echo "<h1>${filename%.*}</h1>" >> $wrkgpath;
sed '/^$/d' $inputpath >> $wrkgpath;

for regex in ${regexes[@]};
do
	sed $regex $wrkgpath > $wrkgpath$tmpext;
	rm $wrkgpath;
	mv $wrkgpath$tmpext $wrkgpath;
done;
echo -e "</body>\n</html>" >> $wrkgpath;

mv $wrkgpath $outputpath;

#
# Restore Internal Field Separator value
#
IFS=$IFS_backup;

exit 0;
