#USAGE
#17net_Tabler.sh {SubID} {age}

sub=$1
age=`echo $2 | cut -c 1`0
study_dir=$3
sdir="${study_dir}/${sub}/qc/INDIV_MAPS"
hdir="/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_17net_TABLES"
NT="${study_dir}/${sub}/qc/INDIV_MAPS/${sub}_17net_table.txt"

if [ -e ${NT} ]
then
	rm ${NT}
fi

touch ${NT}
for roi in `tac ${hdir}/netnames`
do
	if [ ! -e ${NT} ] || [ `grep -c ${roi} ${NT}` -lt 1 ]
	then
		val=`cat ${sdir}/${sub}_${roi}.txt`
		nsubs=`wc -l ${hdir}/${age}/${age}s.txt | awk '{print $1+2}'`
		rmean=`awk '{sum+=$1}END{print sum/NR}' ${hdir}/${age}/${roi}.txt`
		rstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${hdir}/${age}/${roi}.txt`
		Z=`echo $val | awk '{printf "%.2f\n", (($1-"'${rmean}'")/"'${rstd}'")}'`
		perc=`echo ${val} | cat - ${hdir}/${age}/${roi}.txt | sort -n | cat -n | grep ${val} | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)}'`

		echo ${roi} $Z $perc >> ${NT}
	fi
done
