#!/bin/bash
#
# make site list from edi files.
#
cat /dev/null > edi.list
for k in `ls edi/*.edi`; do
	echo $k
	readedi $k '>HEAD' >> edi.list
done
#
mt1ddepslice.sh dep10km.dat edi.list 10000
