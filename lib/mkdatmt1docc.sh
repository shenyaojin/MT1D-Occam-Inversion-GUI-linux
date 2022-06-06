#!/bin/bash
#
#
if [ $# -ne 4 ]; then
	echo "mkdatmt1docc.sh - A tool for making the data file for MT1DOCC routine."
	echo "usage: mkdatmt1docc.sh out.dat rho.asc mode noise"
	echo "       mode=1  use xy-mode rho with specified noise level"
	echo "       mode=2  use yx-mode rho with specified noise level"
	echo "       mode=3  use average rho with specified noise level"
	echo "       mode=4  use xy-mode rho with real noise"
	echo "       mode=5  use yx-mode rho with real noise"
	echo "written by Yang Bo, IGG, CUG, 2013-05-29."
	exit
fi
out=$1
asc=$2
mode=$3
noise=$4
nd=`cat $asc | wc -l`
site=`echo ${asc%.*}`
if [ $# -eq 1 ]; then cm="xy-mode"; fi
if [ $# -eq 4 ]; then cm="xy-mode"; fi
if [ $# -eq 2 ]; then cm="yx-mode"; fi
if [ $# -eq 6 ]; then cm="yx-mode"; fi
if [ $# -eq 3 ]; then cm="average"; fi
#
# output data file.
#-----------------------------------------------------------------------
#
echo "FORMAT:           OCCAM1MTDAT_2.0" > $out
echo "DESCRIPTION:      $site   $cm" >> $out
echo "NUM DATA:         $nd" >> $out
echo "   Period    Type  Datum    Std Error" >> $out
# xy-mode
if [ $mode -eq 1 ]; then
	gawk '{printf "%12.8e  %i  %9.7f  %9.8f \n",1.0/$1,1,log($3)/log(10),"'$noise'"/100/log(10)}' $asc >> $out
fi
# yx-mode
if [ $mode -eq 2 ]; then
	gawk '{printf "%12.8e  %i  %9.7f  %9.8f \n",1.0/$1,1,log($4)/log(10),"'$noise'"/100/log(10)}' $asc >> $out
fi
# average
if [ $mode -eq 3 ]; then
	gawk '{printf "%12.8e  %i  %9.7f  %9.8f \n",1.0/$1,1,log(($3+$4)/2)/log(10),"'$noise'"/100/log(10)}' $asc >> $out
fi
# xy-mode
# noise: %noise = sd / rho
# log10(noise) = %noise/ln(10)
# see <Occam2DMT_FilesAndOptions.pdf> pp.8 for details.
if [ $mode -eq 4 ]; then
	gawk '{printf "%12.8e  %i  %9.7f  %9.8f \n",1.0/$1,1,log($3)/log(10),$11/$3/log(10)}' $asc >> $out
fi
if [ $mode -eq 5 ]; then
	gawk '{printf "%12.8e  %i  %9.7f  %9.8f \n",1.0/$1,1,log($4)/log(10),$12/$4/log(10)}' $asc >> $out
fi
