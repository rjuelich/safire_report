#!/bin/bash

# FS_summary.sh {SubID} {Age}
#
#       Needs to be run from study_dir

#################################
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"

#################################
study_dir=`pwd`
session=$1
age=`echo $2 | cut -c 1`0
norm_dir="${SCRIPT_DIR}/NORMS/FS"
fs_sum=${study_dir}/${session}_FS/stats/${session}_fssum.txt
summary=${study_dir}/${session}_FS/${session}_mri_struc_summary.csv
#concise=${study_dir}/${session}_FS/${session}_mri_struc_concise.csv

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
	grep Intracranial ${session}_FS/stats/aseg.stats | awk -F , '{printf("ICV %d\n", $4)}' >> $fs_sum
fi

if [ `cat $fs_sum | grep -c WM` -lt 1 ]
then
	ICV=`cat ${fs_sum} | grep ICV | awk '{print $2}'`
	cat ${session}_FS/stats/aseg.stats | grep -v \# | awk '{print $5, $3}' | sed 's/_/-/g' | egrep -v 'hypointensities|vessel|5th' | sed s/^Right/R/g | sed s/^Left/L/g | sed 's/White-Matter/WM/g' | awk '{printf "%2.4f %s %s\n", (($2/"'${ICV}'")*100), $1, $2}' | sort -n | awk '{print $2, $1}' >> $fs_sum 
fi

egrep 'Ventricle|Inf-Lat-Vent' $fs_sum | awk '{sum+=$2}END{print "Ventricles-All", sum}' >> $fs_sum

for hem in lh rh
do
	if [ `cat $fs_sum | grep -c ${hem}.fusiform` -lt 1 ]
	then
		egrep -v '\#|unknown|banks' ${session}_FS/stats/${hem}.aparc.stats | awk '{printf "%s.%s %2.3f\n", HEM, $1, $5}' HEM=$hem >> $fs_sum
	fi
done


#  The next step is to normalize based on age distributions for each structure/ROI.

for roi in `cat $fs_sum | egrep -v 'corpuscallosum' | awk '{print $1}'` 
do
	val=`grep $roi $fs_sum | awk '{print $2}'`
	nsessions=`wc -l ${norm_dir}/${age}/aseg_ICV/CSF.txt | awk '{print $1+2}'`
	rmean=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/norm/${roi}.txt`
	rstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/norm/${roi}.txt`
	Z=`echo $val | awk '{print (($1-"'${rmean}'")/"'${rstd}'")}'` 
	perc=`echo ${val} | cat - ${norm_dir}/${age}/norm/${roi}.txt | sort -n | cat -n | grep ${val} | awk '{ if ($2==val) print $1}' val=$val | tail -1 | awk '{print (($1/"'${nsessions}'")*100)}'`
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

# Create summary and concise csv files 
# summary=${session}_FS/${session}_mri_struc_summary.csv
# concise=${session}_FS/${session}_mri_struc_concise.csv

cd ${study_dir}

if [ -e ${summary} ]
then
	rm ${summary}
fi

touch ${summary}

ls ${summary}

header="ICV_raw"
ICV_raw=`grep Intracranial ${session}_FS/stats/aseg.stats | awk -F , '{printf "%d", $4}'`

content="${ICV_raw}"

roi_header=`cat ${session}_FS/stats/aseg.stats | grep -v \# | awk '{print $5, $3}' | sed 's/_/-/g' | egrep -v 'hypointensities|vessel|5th' | sed s/^Right/R/g | sed s/^Left/L/g | sed 's/White-Matter/WM/g' | awk '{printf "%2.4f %s %s\n", (($2/"'${ICV}'")*100), $1, $2}' | awk '{printf ",%s_raw",$2}'`
roi_content=`cat ${session}_FS/stats/aseg.stats | grep -v \# | awk '{print $5, $3}' | sed 's/_/-/g' | egrep -v 'hypointensities|vessel|5th' | sed s/^Right/R/g | sed s/^Left/L/g | sed 's/White-Matter/WM/g' | awk '{printf "%2.4f %s %s\n", (($2/"'${ICV}'")*100), $1, $2}' | awk '{printf ",%2.4f",$1}'`

header="${header}${roi_header}"
content="${content}${roi_content}"

header="${header},Ventricles-All_raw"
ventricles_all_content=`cat ${session}_FS/stats/aseg.stats | grep -v \# | awk '{print $5, $3}' | sed 's/_/-/g' | egrep -v 'hypointensities|vessel|5th' | sed s/^Right/R/g | sed s/^Left/L/g | sed 's/White-Matter/WM/g' | egrep 'Ventricle|Inf-Lat-Vent' | awk '{printf "%2.4f %s %s\n", (($2/"'${ICV}'")*100), $1, $2}' | awk '{sum+=$2}END{print sum}'`

content="${content}${ventricles_all_content}"

for hem in lh rh
do
	hem_header=`egrep -v '\#|unknown|banks' ${session}_FS/stats/${hem}.aparc.stats | awk '{printf ",%s.%s_raw", HEM, $1}' HEM=$hem` 
	header=${header}${hem_header}
	hem_content=`egrep -v '\#|unknown|banks' ${session}_FS/stats/${hem}.aparc.stats | awk '{printf ",%2.3f", $5}'` 
	content=${content}${hem_content}
done

#  The next step is to normalize based on age distributions for each structure/ROI.
nsessions=`wc -l ${norm_dir}/${age}/aseg_ICV/CSF.txt | awk '{print $1+2}'`
num_rois=`echo $header | sed 's/,/ /g' | wc -w` 
roi_iterator=1

while [ ${roi_iterator} -lt ${num_rois} ]
do 
	roi=`echo $header | awk -F , '{print $ITER}' ITER=${roi_iterator} | sed 's/_raw//g'`
	roi_value=`echo $content | awk -F , '{print $ITER}' ITER=${roi_iterator}`
	rmean=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/norm/${roi}.txt`
	rstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/norm/${roi}.txt`
	Z_value=`echo $roi_value | awk '{print (($1-"'${rmean}'")/"'${rstd}'")}'`
	percentile=`echo ${roi_value} | cat - ${norm_dir}/${age}/norm/${roi}.txt | sort -n | cat -n | grep ${roi_value} | awk '{ if ($2==val) print $1}' val=${roi_value} | tail -1 | awk '{print (($1/"'${nsessions}'")*100)}'`

	header="${header},${roi}_Z_value,${roi}_percentile"	
	content="${content},${Z_value},${percentile}"
	
	roi_iterator=$((1+${roi_iterator}))

done

# Get Brain Segmentation Volume BSV and VBR 
age0=`echo ${age} | cut -c 1 | awk '{print $1"0"}'`
bsvnorms="${SCRIPT_DIR}/NORMS/BSV"
nsessions=`cat ${bsvnorms}/${age0}/${age0}s.txt | uniq | wc -l | awk '{print $1+2}'`

bsvm=`awk '{sum+=$1}END{print sum/NR}' ${bsvnorms}/${age0}/BSV.txt`
bsvstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${bsvnorms}/${age0}/BSV.txt`

vbrm=`awk '{sum+=$1}END{print sum/NR}' ${bsvnorms}/${age0}/VBR.txt`
vbrstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${bsvnorms}/${age0}/VBR.txt`

bsvval=`grep "Brain Segmentation Volume" ${session}_FS/stats/aseg.stats | grep -v Ventricles | awk -F , '{printf "%d\n", $4}'`
bsvnvval=`grep "Brain Segmentation Volume" ${session}_FS/stats/aseg.stats | grep Ventricles | grep -v Surf | awk -F , '{printf "%d\n", $4}'`
vbrval=`echo "${bsvnvval} ${bsvval}" | awk '{printf "%f\n", ($2-$1)/$2}'`

BSV_Z_value=`echo ${bsvval} | awk '{printf "%2.4f\n", (($1-"'${bsvm}'")/"'${bsvstd}'")}'`
BSV_percentile=`echo ${bsvval} | cat - ${bsvnorms}/${age0}/BSV.txt | sort -n | cat -n | awk '{if ($2=="'${bsvval}'") print $1}' | tail -1 | awk '{printf "%2.4f\n", (($1/"'${nsessions}'")*100)-0.01}'`

header="${header},BSV_raw,BSV_Z_value,BSV_percentile"
content="${content},${bsvval},${BSV_Z_value},${BSV_percentile}"

VBR_Z_value=`echo ${vbrval} | awk '{printf "%2.4f\n", (($1-"'${vbrm}'")/"'${vbrstd}'")}'`
VBR_percentile=`echo ${vbrval} | cat - ${bsvnorms}/${age0}/VBR.txt | sort -n | cat -n | awk '{if ($2=="'${vbrval}'") print $1}' | tail -1 | awk '{printf "%2.4f\n", (($1/"'${nsessions}'")*100)-0.01}'`

header="${header},VBR_raw,VBR_Z_value,VBR_percentile"
content="${content},${vbrval},${VBR_Z_value},${VBR_percentile}"


echo $header > ${summary}
echo $content >> ${summary}
