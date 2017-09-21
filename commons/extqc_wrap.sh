#!/bin/bash
#
#  extqc_wrap.sh    :  run extqc.py for all BOLD runs in a session
#

sub=$1
datadir=$2
outdir=$3
xnat=$4

if [ ! -e ${outdir}/${sub}/qc ]
then
	mkdir ${outdir}/${sub}/qc
fi

cd ${datadir}

for run in `awk '{print $3}' ${datadir}/${sub}.psf |  sed 's/,/ /g'` #awk -F , '{OFS=" "; print $0}'`
do
	extqc.py -l ${sub} -s ${run} --xnat ${xnat} -o ${outdir}/${sub}/qc
done

