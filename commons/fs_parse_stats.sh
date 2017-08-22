#!/bin/bash

# FS_summary.sh {SubID} {Age}

#################################
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"

#################################
sub=$1
age=`echo $2 | cut -c 1`0
norm_dir="${SCRIPT_DIR}/NORMS/FS"
fs_sum=${sub}_FS/stats/${sub}_fssum.txt

if [ -e ${fs_sum} ]
then
	rm ${fs_sum}
fi

touch ${fs_sum}

fs_table=`echo ${fs_sum} | sed 's/.txt//g'`

if [ -e ${fs_table}_table.txt ]
then 
	rm ${fs_table}_table.txt
fi

if [ `cat $fs_sum | grep -c ICV` -lt 1 ]
then
	grep Intracranial ${sub}_FS/stats/aseg.stats | awk -F , '{printf "ICV %d\n", $4}' >> $fs_sum
fi

if [ `cat $fs_sum | grep -c WM` -lt 1 ]
then
	ICV=`cat ${fs_sum} | grep ICV | awk '{print $2}'`
	cat ${sub}_FS/stats/aseg.stats | grep -v \# | awk '{print $5, $3}' | sed 's/_/-/g' | egrep -v 'hypointensities|vessel|5th' | sed s/^Right/R/g | sed s/^Left/L/g | sed 's/White-Matter/WM/g' | awk '{printf "%.2f %s %s\n", (($2/"'${ICV}'")*100), $1, $2}' | sort -n | awk '{print $2, $1}' >> $fs_sum 
fi

egrep 'Ventricle|Inf-Lat-Vent' $fs_sum | awk '{sum+=$2}END{print "Ventricles-All", sum}' >> $fs_sum

for hem in lh rh
do
	if [ `cat $fs_sum | grep -c ${hem}.fusiform` -lt 1 ]
	then
		egrep -v '\#|unknown|banks' ${sub}_FS/stats/${hem}.aparc.stats | awk '{printf "%s.%s %2.3f\n", HEM, $1, $5}' HEM=$hem >> $fs_sum
	fi
done

#  The next step is to normalize based on age distributions for each structure/ROI.

for roi in `cat $fs_sum | egrep -v 'corpuscallosum' | awk '{print $1}'` 
do
	val=`grep $roi $fs_sum | awk '{print $2}'`
	nsubs=`wc -l ${norm_dir}/${age}/aseg_ICV/CSF.txt | awk '{print $1+2}'`
	rmean=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/norm/${roi}.txt`
	rstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/norm/${roi}.txt`
	Z=`echo $val | awk '{print (($1-"'${rmean}'")/"'${rstd}'")}'` 
	perc=`echo ${val} | cat - ${norm_dir}/${age}/norm/${roi}.txt | sort -n | cat -n | grep ${val} | awk '{ if ($2==val) print $1}' val=$val | tail -1 | awk '{print (($1/"'${nsubs}'")*100)}'`
	echo ${roi}_norm $Z $perc >> $fs_sum
done

for i in `awk '{print $1}' ${fs_sum} | grep norm | egrep -v '^R|^L|^rh|^lh' | sed 's/_norm//g'`
do 
	z=`grep ${i}_norm ${fs_sum} | awk '{print $2}'`
	pct=`grep ${i}_norm ${fs_sum} | awk '{print $3}'`
	echo "${i} ${z} ${pct}" >> ${fs_table}_table.txt
done

for i in `awk '{print $1}' ${fs_sum} | grep norm | grep ^R | cut -c 3- | sed 's/_norm//g'`
do
	lhz=`grep L-${i}_norm ${fs_sum} | awk '{print $2}'`
	lhpct=`grep L-${i}_norm ${fs_sum} | awk '{print $3}'`
	rhz=`grep R-${i}_norm ${fs_sum} | awk '{print $2}'`
	rhpct=`grep R-${i}_norm ${fs_sum} | awk '{print $3}'`
	echo "${i} ${lhz} ${lhpct} ${rhz} ${rhpct}" >> ${fs_table}_table.txt
done

for i in `awk '{print $1}' ${fs_sum} | grep norm | grep ^rh | cut -c 4- | sed 's/_norm//g'`
do
	lhz=`grep lh.${i}_norm ${fs_sum} | awk '{print $2}'`
	lhpct=`grep lh.${i}_norm ${fs_sum} | awk '{print $3}'`
	rhz=`grep rh.${i}_norm ${fs_sum} | awk '{print $2}'`
	rhpct=`grep rh.${i}_norm ${fs_sum} | awk '{print $3}'`
	echo "${i} ${lhz} ${lhpct} ${rhz} ${rhpct}" >> ${fs_table}_table.txt
done
