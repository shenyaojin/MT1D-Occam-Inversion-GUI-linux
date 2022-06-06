#!/bin/bash
#
#
if [ $# -ne 1 ] && [ $# -ne 2 ] && [ $# -ne 4 ] && [ $# -ne 7 ]; then
	echo "mkstartupmt1docc.sh - A tool for making the startup file for MT1DOCC routine."
	echo "usage: mkstartupmt1docc.sh sitename nlayer modfile datfile maxit tol iruf"
	echo "       mkstartupmt1docc.sh sitename [20] [site.mod] [site.dat] [10] [1.0] [1]"
	echo "       mkstartupmt1docc.sh sitename nlayer [site.mod] [site.dat] [10] [1.0] [1]"
	echo "       mkstartupmt1docc.sh sitename nlayer modfile datfile [10] [1.0] [1]"
	echo "written by Yang Bo, IGG, CUG, 2013-05-29."
	exit
fi
#
# get the site name.
#
site=$1
#
# set default parameters.
#
nz=20
mod=$site.mod
dat=$site.dat
maxit=10
tol=1.0
iruf=1
#
# get the optional CML parameters.
#
if [ $# -eq 2 ]; then
	nz=$2
fi
if [ $# -eq 4 ]; then
	nz=$2
	mod=$3
	dat=$4
fi
if [ $# -eq 7 ]; then
	nz=$2
	mod=$3
	dat=$4
	maxit=$5
	tol=$6
	iruf=$7
fi
timestamp=`date "+%x %X"`
#
# output all parameters to startup file.
#-----------------------------------------------------------------------
#
echo 'FORMAT:           OCCAM_1D_MT_1.0' > startup
echo "DESCRIPTION:      $site" >> startup
echo "MODEL FILE:       $mod" >> startup
echo "DATA FILE:        $dat" >> startup
echo "DATE/TIME:        $timestamp" >> startup
echo "MAX ITER:         $maxit" >> startup
echo "REQ TOL:          $tol" >> startup
echo "IRUF:             $iruf" >> startup
echo "DEBUG LEVEL:      1" >> startup
echo "ITERATION:        0" >> startup
echo "PMU:              5.000000" >> startup
echo "RLAST:            0.1000000E+08" >> startup
echo "TLAST:            100.0000" >> startup
echo "IFFTOL:           0" >> startup
echo "NO. PARMS:        $nz" >> startup
for kk in `seq 1 1 $nz`; do
	echo "2.0" >> startup
done
