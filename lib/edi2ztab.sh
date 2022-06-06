#!/bin/bash
if [ $# -ne 1 ] && [ $# -ne 2 ] && [ $# -ne 3 ]; then
	echo "edi2ztab.sh - A tool for converting MT data in EDI format to table format."
	echo " - Usage: edi2ztab.sh file.edi [notipper] [file.ztab] "
	echo " - See also: edi2asc.sh"
	echo ''
	echo ' - Example: convert without tipper: edi2ztab.sh file.edi 0 file.ztab'
	echo '            convert with tipper: edi2ztab.sh file.edi [1] [file.ztab]'
	echo ''
	echo ' - Dependences: gawk, readplt, cat, octave'
	echo ' - Written by Bo Yang, ZJU, 2018-08-29.'
	echo ' - Last modified: 2022-04-06 19:41:19.'
	echo ' - Change log:'
	echo '   * 2021-03-21: BUG Fixed: no tipper variance output!'
	echo '   * 2021-10-06: ADD: supports for skipping tippers!'
	exit
fi
edi=$1
bTipper=1
f1=`echo ${edi%.*}`
f=`echo ${f1##*/}`
asc=$f.ztab
# get the cmd line option.
if [ $# -eq 2 ]; then
	bTipper=$2
fi
if [ $# -eq 3 ]; then
	asc=$3
fi
#
# get the data for each keyword.
#
#kwlist="FREQ RHOXX RHOXY RHOYX RHOYY PHSXX PHSXY PHSYX PHSYY RHOXX.VAR RHOXY.VAR RHOYX.VAR RHOYY.VAR PHSXX.VAR PHSXY.VAR PHSYX.VAR PHSYY.VAR ZXXR ZXYR ZYXR ZYYR ZXXI ZXYI ZYXI ZYYI ZXX.VAR ZXY.VAR ZYX.VAR ZYY.VAR"
if [ $bTipper -gt 0 ];then
	kwlist="FREQ ZXXR ZXYR ZYXR ZYYR ZXXI ZXYI ZYXI ZYYI ZXX.VAR ZXY.VAR ZYX.VAR ZYY.VAR TXR.EXP TXI.EXP TYR.EXP TYI.EXP TXVAR.EXP TYVAR.EXP"
else
	kwlist="FREQ ZXXR ZXYR ZYXR ZYYR ZXXI ZXYI ZYXI ZYYI ZXX.VAR ZXY.VAR ZYX.VAR ZYY.VAR"
fi
#
kc=0
cat /dev/null > temp.txt
for kw in $kwlist
do
	#echo $kw
	lib/readedi $edi ">"$kw | gawk '{a[FNR]=$1}END{for(i=1;i<=FNR;i++){printf "%e  ",a[i]};printf "\n"}' >> temp.txt
done
gawk '{for(i=1;i<=NF;i++){a[FNR,i]=$i}}END{for(i=1;i<=NF;i++){for(j=1;j<=FNR;j++){printf a[j,i]"	"}print ""}}' temp.txt > $asc
rm temp.txt

#
# convert M to Z by times 4*pi*10^-4 in OCTAVE.
#
cp $asc temp.txt
#
# make the octave script.
#
OSC=edi2ztab_octave.m
cat /dev/null > $OSC
cat >> $OSC << EOF
load('temp.txt');
freq = temp(:,1);
omega= 2.0 * pi * freq;
mu  = 4 * pi * 1.e-7;
II  = sqrt(-1);
zxx = temp(:,2) + temp(:,6) * II;
zxy = temp(:,3) + temp(:,7) * II;
zyx = temp(:,4) + temp(:,8) * II;
zyy = temp(:,5) + temp(:,9) * II;
dzxx= temp(:,10);
dzxy= temp(:,11);
dzyx= temp(:,12);
dzyy= temp(:,13);
EOF
#
if [ $bTipper -gt 0 ];then
cat >> $OSC << EOF
tzxr= temp(:,14);
tzxi= temp(:,15);
tzyr= temp(:,16);
tzyi= temp(:,17);
dtzx= temp(:,18);
dtzy= temp(:,19);
EOF
fi
#
cat >> $OSC << EOF
drhoxx = 2 * mu ./ omega .* abs(zxx) .* sqrt(dzxx) * 1.0e6;
drhoxy = 2 * mu ./ omega .* abs(zxy) .* sqrt(dzxy) * 1.0e6;
drhoyx = 2 * mu ./ omega .* abs(zyx) .* sqrt(dzyx) * 1.0e6;
drhoyy = 2 * mu ./ omega .* abs(zyy) .* sqrt(dzyy) * 1.0e6;
dphsxx = sqrt(dzxx) ./ abs(zxx) * 180.0 / pi;
dphsxy = sqrt(dzxy) ./ abs(zxy) * 180.0 / pi;
dphsyx = sqrt(dzyx) ./ abs(zyx) * 180.0 / pi;
dphsyy = sqrt(dzyy) ./ abs(zyy) * 180.0 / pi;
zxx = zxx * mu * 10^3;
zxy = zxy * mu * 10^3;
zyx = zyx * mu * 10^3;
zyy = zyy * mu * 10^3;
dzxx = sqrt(dzxx) * 4 * pi * 1e-4;
dzxy = sqrt(dzxy) * 4 * pi * 1e-4;
dzyx = sqrt(dzyx) * 4 * pi * 1e-4;
dzyy = sqrt(dzyy) * 4 * pi * 1e-4;
rhoxx = abs(zxx).^2 ./ omega / mu;
rhoxy = abs(zxy).^2 ./ omega / mu;
rhoyx = abs(zyx).^2 ./ omega / mu;
rhoyy = abs(zyy).^2 ./ omega / mu;
phsxx = atan2(imag(zxx),real(zxx)) * 180.0 / pi;
phsxy = atan2(imag(zxy),real(zxy)) * 180.0 / pi;
phsyx = atan2(imag(zyx),real(zyx)) * 180.0 / pi;
phsyy = atan2(imag(zyy),real(zyy)) * 180.0 / pi;
zxxr = real(zxx);
zxyr = real(zxy);
zyxr = real(zyx);
zyyr = real(zyy);
zxxi = imag(zxx);
zxyi = imag(zxy);
zyxi = imag(zyx);
zyyi = imag(zyy);
EOF
#
if [ $bTipper -gt 0 ];then
cat >> $OSC << EOF
out=[freq rhoxx rhoxy rhoyx rhoyy phsxx phsxy phsyx phsyy drhoxx drhoxy drhoyx drhoyy dphsxx dphsxy dphsyx dphsyy zxxr zxyr zyxr zyyr zxxi zxyi zyxi zyyi dzxx dzxy dzyx dzyy tzxr tzxi tzyr tzyi dtzx dtzy];
EOF
else
cat >> $OSC << EOF
out=[freq rhoxx rhoxy rhoyx rhoyy phsxx phsxy phsyx phsyy drhoxx drhoxy drhoyx drhoyy dphsxx dphsxy dphsyx dphsyy zxxr zxyr zyxr zyyr zxxi zxyi zyxi zyyi dzxx dzxy dzyx dzyy];
EOF
fi
echo 'save octaveout.asc out -ascii;' >> $OSC
#
# run the octave script.
#
cat $OSC | octave -qf
#out=[freq zxxr zxxi dzxx zxyr zxyi dzxy zyxr zyxi dzyx zyyr zyyi dzyy freq freq freq freq rhoxy phsxy drhoxy dphsxy rhoyx phsyx drhoyx dphsyx];
#       1    2     3     4     5     6     7     8     9     10      11    12     13     14     15     16     17    18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33   34   35
#out=[freq rhoxx rhoxy rhoyx rhoyy phsxx phsxy phsyx phsyy drhoxx drhoxy drhoyx drhoyy dphsxx dphsxy dphsyx dphsyy zxxr zxyr zyxr zyyr zxxi zxyi zyxi zyyi dzxx dzxy dzyx dzyy tzxr tzxi tzyr tzyi dtzx dtzy];
rm temp.txt $OSC
mv octaveout.asc $asc
