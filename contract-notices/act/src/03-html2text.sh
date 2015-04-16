#!/bin/sh

mkdir -p export/text
ls -1 export/individual/ | parallel -j8 html2text -o "export/text/{}" "export/individual/{}"
