#!/bin/bash

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

#if [ `ls -1 ${datadir}/${sub}/bold | grep -c ^0 | awk '{print $1}'` -ge 2 ]
#then
#	run1=`ls -1 ${datadir}/${sub}/bold | grep ^0 | head -1 | sed s/^0//g | sed s/^0//g`
#	run2=`ls -1 ${datadir}/${sub}/bold | grep ^0 | head -2 | tail -1 | sed s/^0//g | sed s/^0//g`
#	extqc.py -l ${sub} -s ${run1} --xnat ${xnat} -o ${outdir}/${sub}/qc
#	extqc.py -l ${sub} -s ${run2} --xnat ${xnat} -o ${outdir}/${sub}/qc
#else
#	run1=`ls -1 ${datadir}/${sub}/bold | grep ^0 | head -1 | sed s/^0//g | sed s/^0//g`
#	extqc.py -l ${sub} -s ${run1} --xnat ${xnat} -o ${outdir}/${sub}/qc
#fi
