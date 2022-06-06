#!/bin/bash
site=$1
#
# see if there is a mk.para file exist.
#
if [ -e mk.para ]; then echo "mk.para existed!"; exit; fi
echo "site="$site > mk.para
echo "inv="$site.RECV >> mk.para
echo "nlayer=20" >> mk.para
echo "mfile="$site.mod >> mk.para
echo "dfile="$site.dat >> mk.para
echo "maxit=10" >> mk.para
echo "tol=1.2" >> mk.para
echo "mode=3" >> mk.para
echo "noise=6" >> mk.para
