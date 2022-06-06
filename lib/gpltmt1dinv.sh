#!/bin/bash
#
#
if [ $# -ne 6 ]
then
	echo "gpltmt1dinv.sh - A tool to draw the MT 1D inversion result."
	echo "usage: gpltmt1dinv.sh sitename misfit roughness model.txt resp.txt out.png"
	echo "written by Yang Bo, IGG, CUG, 2013-05-29."
	exit
fi
site=$1
mis=$2
ruf=$3
mod=$4
dat=$5
out=$6
#==========================parameters box===============================
#colorxy='rgbcolor "#F62817"'
#coloryx='rgbcolor "#2B60DE"'

colorxy='rgbcolor "#DF0029"'
coloryx='rgbcolor "#205AA7"'

#colorxy='rgbcolor "#B2001F"'
#coloryx='rgbcolor "#00A06B"'

#colorxy=1
#coloryx=3
ptypexy=4
ptypeyx=7
psize=1.2
leftm=11
tit='Site: '$site'  Misfit='$mis'  Roughness='$ruf
#=======================end parameters box==============================
#
# Generate fig using gnuplot.
#
gnuplot << EOF
#set term epslatex standalone linewidth 2 color size 8,5
set term pngcairo linewidth 1 size 20cm,30cm
set grid linewidth 2
set output "$out"
set xrange [] reverse
set multiplot
#
# draw data fittness.
#
set title "$tit"
set mxtics 10
set mytics 10
set xlabel "Frequency(Hz)"
set ylabel 'Apparent resis.(ohm-m)'
set logscale xy
#set format x "%g"
set format x "10^{%T}"
#set format y "%g"
set format y "10^{%T}"
set size 1,0.54
set origin 0,0.46
#set key left
set lmargin $leftm
plot "${dat}" using 1:3:4 with yerrorbars linewidth 2 linetype 1 pointtype $ptypexy pointsize $psize linecolor $colorxy title 'Observed', \
     "${dat}" using 1:2 with lines linewidth 2 linetype 1 linecolor $coloryx title 'Predicted'
#
# draw model.
#
set xlabel "Depth(m)"
set ylabel 'Resis.(ohm-m)'
set mxtics 10
set mytics 1
unset title
set xrange [] noreverse
#unset logscale x
#set format y "%g"
set size 1,0.46
set origin 0,0
set lmargin $leftm
plot "${mod}" using 1:2 with lines linewidth 2 linetype 1 linecolor $coloryx title 'Recovered'
unset multiplot
EOF
