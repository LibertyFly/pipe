#!/bin/bash
sed 's///g'|sed 's/\n//g'|awk -F ","  -f /usr/local/functionlib/awk/csvto64json.awk |sed 's/,\(.\)$/\1/'|sed 's/mysplit/,/g'
