#!/bin/bash

##############################3
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
commons="${SCRIPT_DIR}/commons"
#################################

sub=$1
age=`echo $2 | cut -c 1`0
study_dir=$3
sdir="${study_dir}/${sub}/qc/INDIV_MAPS"
norm_dir="${SCRIPT_DIR}/NORMS/17NET"
NT="${study_dir}/${sub}/qc/INDIV_MAPS/${sub}_17net_table.txt"

# Create summary and concise csv files
summary=${study_dir}/${sub}/${sub}_mri_func_summary.csv
#concise=${study_dir}/${sub}/${sub}_mri_func_concise.csv

if [ -e ${NT} ]
then
	rm ${NT}
fi

touch ${NT}

# create summary and concise csv files
if [ -e ${summary} ]
then
        rm ${summary}
fi
touch ${summary}

unset header content

for roi in `cat ${norm_dir}/netnames`
do
	if [ ! -e ${NT} ] || [ `grep -c ${roi} ${NT}` -lt 1 ]
	then
		val=`cat ${sdir}/${sub}_${roi}.txt`
		nsubs=`wc -l ${norm_dir}/${age}/${age}s.txt | awk '{print $1+2}'`
		rmean=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/${roi}.txt`
		rstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/${roi}.txt`
		Z=`echo $val | awk '{printf "%.2f\n", (($1-"'${rmean}'")/"'${rstd}'")}'`
		perc=`echo ${val} | cat - ${norm_dir}/${age}/${roi}.txt | sort -n | cat -n | grep ${val} | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)}'`

		echo ${roi} $Z $perc >> ${NT}
	        header="${header},${roi}_raw,${roi}_Z_value,${roi}_percentile"
	        content="${content},${val},${Z},${perc}"

	fi
done

echo $header > ${summary}
echo $content >> ${summary}

exit 0
