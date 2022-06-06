#!/bin/bash
#
#
if [ $# -ne 2 ]
then
	echo "pltocciter.sh - A tool to draw the MT 1D Occam's inversion result."
	echo "usage: pltocciter.sh site numberofiteration"
	echo "The script will automatically read RECV05 RESP05 MISFIT file get the data."
	echo "written by Yang Bo, IGG, CUG, 2013-05-29."
	exit
fi
site=$1
iter=$2
mod=RECV$iter
dat=RESP$iter
#
# get the misfit and roughness from MISFIT file.
#
mis=`sed -n "${iter},${iter}p" MISFIT | gawk '{printf "%5.2f",$2}'`
ruf=`sed -n "${iter},${iter}p" MISFIT | gawk '{printf "%5.2f",$3}'`
#
# call the gnuplot script.
#
../lib/gpltmt1dinv.sh $site $mis $ruf $mod $dat $site.png
