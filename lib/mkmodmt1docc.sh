#!/bin/bash
if [ $# -ne 4 ]; then
	echo "mkmodmt1docc.sh - A tool for making the initial model file for MT1DOCC routine."
	echo "usage: mkmodmt1docc.sh out.mod rho.asc nlayer mode"
	echo "written by Yang Bo, IGG, CUG, 2013-05-29."
	exit
fi
out=$1
asc=$2
nz=$3
mode=$4
site=`echo ${asc%.*}`
#
# output data file.
#-----------------------------------------------------------------------
#
echo "FORMAT:           OCCAM1MTMOD_2.0" > $out
echo "MODEL NAME:       $out" >> $out
echo "DESCRIPTION:      $site" >> $out
echo "NUM LAYERS:       $nz" >> $out
echo " THICKNESS     RESISTIVITY  PENALTY  PREDJUDICE  PENALTY " >> $out
#
# compute thickness by using Octave.
#
if [ $mode -eq 1 ]; then mode=3; fi
if [ $mode -eq 4 ]; then mode=3; fi
if [ $mode -eq 2 ]; then mode=4; fi
if [ $mode -eq 5 ]; then mode=4; fi
if [ $mode -eq 3 ]; then mode=3; fi
octave -qf << EOF
asc=load('$asc');
freq=asc(:,1);
nz=$nz;
nf=length(freq);
rho=asc(:,$mode);
thick(1)=503*sqrt(rho(1)/freq(1))*0.6;
rho_ave=10.^(sum(log10(rho))/nf); %% geometric average.
maxdepth=503*sqrt(rho_ave/freq(nf))*0.9;
fac=(maxdepth/thick(1))**(1/(nz-1));
dep(1)=thick(1);
for k=2:nz
	dep(k)=dep(k-1)*fac;
end
thick(2:nz)=dep(2:nz)-dep(1:nz-1);
thick=thick';
save octaveout.thick thick -ascii;
EOF
#
# output layers thickness.
#-----------------------------------------------------------------------
#
gawk '{printf "%15.10e     %5.2f     %i      %8.5f     %i\n",$1,-1.0,1,0.0,0}' octaveout.thick >> $out
rm octaveout.thick
