#!/bin/bash
sed 's///g'|sed 's/\n//g'|awk -F ","  -f /usr/local/functionlib/awk/csvtojson.awk |sed 's/,\(.\)$/\1/'|sed 's/mysplit/,/g'
