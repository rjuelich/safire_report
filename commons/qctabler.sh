#!/bin/bash

###################################
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
commons="${SCRIPT_DIR}/commons"USAGE
#####################################
#qctabler.sh {SubID} {age}

sub=$1
age=`echo $2 | cut -c 1`0
study_dir=$3
sdir="${study_dir}/${sub}/qc/INDIV_MAPS"
norm_dir="${SCRIPT_DIR}/NORMS/QC"
qct="${sdir}/${sub}_qc_table.txt"
nsubs=`wc -l ${norm_dir}/${age}/${age}s.txt | awk '{print $1+2}'`

# Create summary and concise csv files
summary="${study_dir}/${sub}/${sub}_mri_func_summary.csv"
# concise="${study_dir}/${sub}/${sub}_mri_func_concise.csv"

if [ -e ${summary} ]
then
	header=`cat ${summary} | head -1`
	content=`cat ${summary} | tail -1`
else
	header=""
	content=""
fi

if [ -e ${qct} ]
then
	rm ${qct}
fi

### Get sub values
rv=`awk -F , '{print $1}' ${sdir}/${sub}_scatter.csv`
av=`awk -F , '{print $2}' ${sdir}/${sub}_scatter.csv`
bv=`awk -F , '{print $3}' ${sdir}/${sub}_scatter.csv`
snr1=`awk '{print $2}' ${sdir}/SNR.txt | head -1`

if [ `wc -l ${sdir}/SNR.txt | awk '{print $1}'` -ge 2 ]
then
	snr2=`awk '{print $2}' ${sdir}/SNR.txt | tail -1`
else
	snr2="NA"
fi

### Get age specific means/stds

rmean=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/R.txt`
rstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/R.txt`

amean=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/A.txt`
astd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/A.txt`

bmean=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/B.txt`
bstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/B.txt`

snrmean=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/SNR.txt`
snrstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/SNR.txt`

### Calculate Z-score/percentiles

rz=`echo $rv | awk '{printf "%.2f\n", (($1-"'${rmean}'")/"'${rstd}'")}'`
rpct=`echo ${rv} | cat - ${norm_dir}/${age}/R.txt | sort -n | cat -n | grep ${rv} | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)}'`

az=`echo $av | awk '{printf "%.2f\n", (($1-"'${amean}'")/"'${astd}'")}'`
apct=`echo ${av} | cat - ${norm_dir}/${age}/A.txt | sort -n | cat -n | grep ${av} | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)}'`


bz=`echo $bv | awk '{printf "%.2f\n", (($1-"'${bmean}'")/"'${bstd}'")}'`
bv1=`echo ${bv} | awk '{print $1+1}'`
bpct=`echo ${bv} | cat - ${norm_dir}/${age}/B.txt | sort -n | awk '{print 1+$1}' | cat -n | grep ${bv1} | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)}'`


snr1z=`echo $snr1 | awk '{printf "%.2f\n", (($1-"'${snrmean}'")/"'${snrstd}'")}'`
snr1pct=`echo ${snr1} | cat - ${norm_dir}/${age}/SNR.txt | sort -n | cat -n | grep ${snr1} | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)}'`


if [ `echo ${snr2}` != "NA" ]
then
	snr2z=`echo ${snr2} | awk '{printf "%.2f\n", (($1-"'${snrmean}'")/"'${snrstd}'")}'`
	snr2pct=`echo ${snr2} | cat - ${norm_dir}/${age}/SNR.txt | sort -n | cat -n | grep ${snr2} | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)}'`
fi

echo "SNR1 $snr1 $snr1z $snr1pct" >> ${qct}
roi="SNR1"
header="${header},${roi}_raw,${roi}_Z_value,${roi}_percentile"
content="${content},${snr1},${snr1z},${snrpct}"

if [ `echo ${snr2}` != "NA" ]
then
	echo "SNR2 $snr2 $snr2z $snr2pct" >> ${qct}
	roi="SNR2"
	header="${header},${roi}_raw,${roi}_Z_value,${roi}_percentile"
	content="${content},${snr2},${snr2z},${snr2pct}"
fi

echo "Correlation $rv $rz $rpct" >> ${qct}
echo "Slope $av $az $apct" >> ${qct}
echo "Intercept $bv $bz $bpct" >> ${qct}

roi="Correlation"
header="${header},${roi}_raw,${roi}_Z_value,${roi}_percentile"
content="${content},${rv},${rz},${rpct}"

roi="Slope"
header="${header},${roi}_raw,${roi}_Z_value,${roi}_percentile"
content="${content},${av},${az},${apct}"

roi="Intercept"
header="${header},${roi}_raw,${roi}_Z_value,${roi}_percentile"
content="${content},${bv},${bz},${bpct}"



echo $header > ${summary}
echo $content >> ${summary}


exit 0


