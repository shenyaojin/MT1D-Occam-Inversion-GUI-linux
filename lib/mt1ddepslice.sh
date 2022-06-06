#!/bin/bash
if [ $# -ne 3 ]
then
	echo "mt1ddepslice.sh - A tool to generate MT resistivity depth slice data from 1D inversion."
	echo "usage: mt1ddepslice.sh out.dat site.list depth"
	echo "written by Yang Bo, IGG, CUG, 2013-06-06."
	exit
fi
out=$1
site=$2
dep=$3
#
# loop over sites.
#
cat /dev/null > tempres.txt
gawk '{print $1".RECV"}' $site | tr -d $'\r' > tempsite.txt
for ss in `cat tempsite.txt`; do
octave -qf << EOF
mod=load('$ss');
dep=mod(:,1);
res=mod(:,2);
dep(3:2:end)=dep(3:2:end)+0.1;
itp=interp1(dep,res,$dep,'nearest');
fid=fopen('tempres.txt','a');
fprintf(fid,'%20.12e\n',itp);
fclose(fid);
EOF
done
#
# combine the resistivity colum to siteloc file.
#
gawk '{getline a<"tempres.txt"; print $0,a}' $site > $out
#
# clean.
#
rm tempres.txt tempsite.txt
