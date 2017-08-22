#!/bin/bash
#USAGE
#extqc_tabler.sh {SubID} {age}


SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"

sub=$1
age=`echo $2 | cut -c 1`0
study_dir=$3
sdir="${study_dir}/${sub}"
norm_dir="${SCRIPT_DIR}/NORMS/EXTQC"
extqct="${sdir}/${sub}_extqc_table.txt"
nsubs=`wc -l ${norm_dir}/${age}/${age}s.txt | awk '{print $1+2}'`


if [ -e ${extqct} ]
then
       	rm ${extqct}
fi

if [ `ls -1 ${sdir}/qc/extended-qc | grep -c auto_report.txt | awk '{print $1}'` -ge 2 ]
then
       	extqc1f=`ls -1 ${sdir}/qc/extended-qc | grep auto_report.txt | head -1`
       	extqc2f=`ls -1 ${sdir}/qc/extended-qc | grep auto_report.txt | tail -1`
       	extqc1=`cat ${sdir}/qc/extended-qc/${extqc1f} | egrep 'qc_Mean|qc_Stdev|qc_sSNR|mot_rel_xyz_mean|mot_rel_xyz_sd|mot_rel_xyz_max|mot_rel_xyz_1mm|mot_rel_xyz_5mm' | grep -v old | awk '{print $2}' | paste -s -d , -`
       	extqc2=`cat ${sdir}/qc/extended-qc/${extqc2f} | egrep 'qc_Mean|qc_Stdev|qc_sSNR|mot_rel_xyz_mean|mot_rel_xyz_sd|mot_rel_xyz_max|mot_rel_xyz_1mm|mot_rel_xyz_5mm' | grep -v old | awk '{print $2}' | paste -s -d , -`
else
       	extqc1=`cat ${sdir}/qc/extended-qc/*auto_report.txt | egrep 'qc_Mean|qc_Stdev|qc_sSNR|mot_rel_xyz_mean|mot_rel_xyz_sd|mot_rel_xyz_max|mot_rel_xyz_1mm|mot_rel_xyz_5mm' | grep -v old | awk '{print $2}' | paste -s -d , -`
fi


ntrs=`cat ${sdir}/qc/extended-qc/*auto_report.txt | grep qc_N_Tps | awk '{print $2}' | head -1`

### Get n2642 sample Mean/Std
qc_MeanAvg=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/qc_Mean.txt`
qc_MeanStd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/qc_Mean.txt`

qc_StdevAvg=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/qc_Stdev.txt`
qc_StdevStd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/qc_Stdev.txt`

qc_sSNRAvg=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/qc_sSNR.txt`
qc_sSNRStd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/qc_sSNR.txt`

mot_rel_xyz_meanAvg=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/mot_rel_xyz_mean.txt`
mot_rel_xyz_meanStd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/mot_rel_xyz_mean.txt`

mot_rel_xyz_sdAvg=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/mot_rel_xyz_sd.txt`
mot_rel_xyz_sdStd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/mot_rel_xyz_sd.txt`

mot_rel_xyz_maxAvg=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/mot_rel_xyz_max.txt`
mot_rel_xyz_maxStd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/mot_rel_xyz_max.txt`

mot_rel_xyz_1mmAvg=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/mot_rel_xyz_1mm.txt`
mot_rel_xyz_1mmStd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/mot_rel_xyz_1mm.txt`

mot_rel_xyz_5mmAvg=`awk '{sum+=$1}END{print sum/NR}' ${norm_dir}/${age}/mot_rel_xyz_5mm.txt`
mot_rel_xyz_5mmStd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${norm_dir}/${age}/mot_rel_xyz_5mm.txt`


### Get sub values
if [ ${extqc2} ]
then
       	qc_Mean1=`echo ${extqc1} | awk -F , '{print $1}'`
       	qc_Stdev1=`echo ${extqc1} | awk -F , '{print $2}'`
       	qc_sSNR1=`echo ${extqc1} | awk -F , '{print $3}'`
       	mot_rel_xyz_mean1=`echo ${extqc1} | awk -F , '{print $4}'`
       	mot_rel_xyz_sd1=`echo ${extqc1} | awk -F , '{print $5}'`
       	mot_rel_xyz_max1=`echo ${extqc1} | awk -F , '{print $6}'`
       	mot_rel_xyz_1mm1=`echo ${extqc1} | awk -F , '{print int($7/(ntrs/120))}' ntrs=${ntrs}`
       	mot_rel_xyz_5mm1=`echo ${extqc1} | awk -F , '{print int($8/(ntrs/120))}' ntrs=${ntrs}`
       	qc_Mean2=`echo ${extqc2} | awk -F , '{print $1}'`
       	qc_Stdev2=`echo ${extqc2} | awk -F , '{print $2}'`
       	qc_sSNR2=`echo ${extqc2} | awk -F , '{print $3}'`
       	mot_rel_xyz_mean2=`echo ${extqc2} | awk -F , '{print $4}'`
       	mot_rel_xyz_sd2=`echo ${extqc2} | awk -F , '{print $5}'`
       	mot_rel_xyz_max2=`echo ${extqc2} | awk -F , '{print $6}'`
       	mot_rel_xyz_1mm2=`echo ${extqc2} | awk -F , '{print int($7/(ntrs/120))}' ntrs=${ntrs}`
       	mot_rel_xyz_5mm2=`echo ${extqc2} | awk -F , '{print int($8/(ntrs/120))}' ntrs=${ntrs}`

       	qc_Mean1z=`echo $qc_Mean1 | awk '{printf "%.2f\n", (($1-"'${qc_MeanAvg}'")/"'${qc_MeanStd}'")}'`
       	qc_Mean1pct=`echo ${qc_Mean1} | cat - ${norm_dir}/${age}/qc_Mean.txt | sort -n | cat -n | awk '{if ($2=="'${qc_Mean1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	qc_Stdev1z=`echo $qc_Stdev1 | awk '{printf "%.2f\n", (($1-"'${qc_StdevAvg}'")/"'${qc_StdevStd}'")}'`
       	qc_Stdev1pct=`echo ${qc_Stdev1} | cat - ${norm_dir}/${age}/qc_Stdev.txt | sort -n | cat -n | awk '{if ($2=="'${qc_Stdev1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	qc_sSNR1z=`echo $qc_sSNR1 | awk '{printf "%.2f\n", (($1-"'${qc_sSNRAvg}'")/"'${qc_sSNRStd}'")}'`
       	qc_sSNR1pct=`echo ${qc_sSNR1} | cat - ${norm_dir}/${age}/qc_sSNR.txt | sort -n | cat -n | awk '{if ($2=="'${qc_sSNR1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_mean1z=`echo $mot_rel_xyz_mean1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_meanAvg}'")/"'${mot_rel_xyz_meanStd}'")}'`
       	mot_rel_xyz_mean1pct=`echo ${mot_rel_xyz_mean1} | cat - ${norm_dir}/${age}/mot_rel_xyz_mean.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_mean1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_sd1z=`echo $mot_rel_xyz_sd1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_sdAvg}'")/"'${mot_rel_xyz_sdStd}'")}'`
       	mot_rel_xyz_sd1pct=`echo ${mot_rel_xyz_sd1} | cat - ${norm_dir}/${age}/mot_rel_xyz_sd.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_sd1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_max1z=`echo $mot_rel_xyz_max1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_maxAvg}'")/"'${mot_rel_xyz_maxStd}'")}'`
       	mot_rel_xyz_max1pct=`echo ${mot_rel_xyz_max1} | cat - ${norm_dir}/${age}/mot_rel_xyz_max.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_max1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`
       	mot_rel_xyz_1mm1z=`echo $mot_rel_xyz_1mm1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_1mmAvg}'")/"'${mot_rel_xyz_1mmStd}'")}'`
       	mot_rel_xyz_1mm1pct=`echo ${mot_rel_xyz_1mm1} | cat - ${norm_dir}/${age}/mot_rel_xyz_1mm.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_1mm1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_5mm1z=`echo $mot_rel_xyz_5mm1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_5mmAvg}'")/"'${mot_rel_xyz_5mmStd}'")}'`
       	mot_rel_xyz_5mm1pct=`echo ${mot_rel_xyz_5mm1} | cat - ${norm_dir}/${age}/mot_rel_xyz_5mm.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_5mm1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	qc_Mean2z=`echo $qc_Mean2 | awk '{printf "%.2f\n", (($1-"'${qc_MeanAvg}'")/"'${qc_MeanStd}'")}'`
       	qc_Mean2pct=`echo ${qc_Mean2} | cat - ${norm_dir}/${age}/qc_Mean.txt | sort -n | cat -n | awk '{if ($2=="'${qc_Mean2}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	qc_Stdev2z=`echo $qc_Stdev2 | awk '{printf "%.2f\n", (($1-"'${qc_StdevAvg}'")/"'${qc_StdevStd}'")}'`
       	qc_Stdev2pct=`echo ${qc_Stdev2} | cat - ${norm_dir}/${age}/qc_Stdev.txt | sort -n | cat -n | awk '{if ($2=="'${qc_Stdev2}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	qc_sSNR2z=`echo $qc_sSNR2 | awk '{printf "%.2f\n", (($1-"'${qc_sSNRAvg}'")/"'${qc_sSNRStd}'")}'`
       	qc_sSNR2pct=`echo ${qc_sSNR2} | cat - ${norm_dir}/${age}/qc_sSNR.txt | sort -n | cat -n | awk '{if ($2=="'${qc_sSNR2}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_mean2z=`echo $mot_rel_xyz_mean2 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_meanAvg}'")/"'${mot_rel_xyz_meanStd}'")}'`
       	mot_rel_xyz_mean2pct=`echo ${mot_rel_xyz_mean2} | cat - ${norm_dir}/${age}/mot_rel_xyz_mean.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_mean2}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_sd2z=`echo $mot_rel_xyz_sd2 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_sdAvg}'")/"'${mot_rel_xyz_sdStd}'")}'`
       	mot_rel_xyz_sd2pct=`echo ${mot_rel_xyz_sd2} | cat - ${norm_dir}/${age}/mot_rel_xyz_sd.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_sd2}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_max2z=`echo $mot_rel_xyz_max2 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_maxAvg}'")/"'${mot_rel_xyz_maxStd}'")}'`
       	mot_rel_xyz_max2pct=`echo ${mot_rel_xyz_max2} | cat - ${norm_dir}/${age}/mot_rel_xyz_max.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_max2}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`
       	mot_rel_xyz_1mm2z=`echo $mot_rel_xyz_1mm2 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_1mmAvg}'")/"'${mot_rel_xyz_1mmStd}'")}'`
       	mot_rel_xyz_1mm2pct=`echo ${mot_rel_xyz_1mm2} | cat - ${norm_dir}/${age}/mot_rel_xyz_1mm.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_1mm2}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_5mm2z=`echo $mot_rel_xyz_5mm2 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_5mmAvg}'")/"'${mot_rel_xyz_5mmStd}'")}'`
       	mot_rel_xyz_5mm2pct=`echo ${mot_rel_xyz_5mm2} | cat - ${norm_dir}/${age}/mot_rel_xyz_5mm.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_5mm2}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	echo "QCmean ${qc_Mean1} ${qc_Mean1pct} ${qc_Mean2} ${qc_Mean2pct}" >> ${extqct}
       	echo "QCstd ${qc_Stdev1} ${qc_Stdev1pct} ${qc_Stdev2} ${qc_Stdev2pct}" >> ${extqct}
	echo "QCsSNR ${qc_sSNR1} ${qc_sSNR1pct} ${qc_sSNR2} ${qc_sSNR2pct}" >> ${extqct}
       	echo "mot_rel_xyz_mean ${mot_rel_xyz_mean1} ${mot_rel_xyz_mean1pct} ${mot_rel_xyz_mean2} ${mot_rel_xyz_mean2pct}" >> ${extqct}
       	echo "mot_rel_xyz_sd ${mot_rel_xyz_sd1} ${mot_rel_xyz_sd1pct} ${mot_rel_xyz_sd2} ${mot_rel_xyz_sd2pct}" >> ${extqct}
       	echo "mot_rel_xyz_max ${mot_rel_xyz_max1} ${mot_rel_xyz_max1pct} ${mot_rel_xyz_max2} ${mot_rel_xyz_max2pct}" >> ${extqct}
       	echo "mot_rel_xyz_1mm ${mot_rel_xyz_1mm1} ${mot_rel_xyz_1mm1pct}  ${mot_rel_xyz_1mm2} ${mot_rel_xyz_1mm2pct}" >> ${extqct}
       	echo "mot_rel_xyz_5mm ${mot_rel_xyz_5mm1} ${mot_rel_xyz_5mm1pct} ${mot_rel_xyz_5mm2} ${mot_rel_xyz_5mm1pct}" >> ${extqct}
else
       	qc_Mean1=`echo ${extqc1} | awk -F , '{print $1}'`
       	qc_Stdev1=`echo ${extqc1} | awk -F , '{print $2}'`
       	qc_sSNR1=`echo ${extqc1} | awk -F , '{print $3}'`
       	mot_rel_xyz_mean1=`echo ${extqc1} | awk -F , '{print $4}'`
       	mot_rel_xyz_sd1=`echo ${extqc1} | awk -F , '{print $5}'`
       	mot_rel_xyz_max1=`echo ${extqc1} | awk -F , '{print $6}'`
       	mot_rel_xyz_1mm1=`echo ${extqc1} | awk -F , '{print $7}'`
       	mot_rel_xyz_5mm1=`echo ${extqc1} | awk -F , '{print $8}'`

       	qc_Mean1z=`echo $qc_Mean1 | awk '{printf "%.2f\n", (($1-"'${qc_MeanAvg}'")/"'${qc_MeanStd}'")}'`
       	qc_Mean1pct=`echo ${qc_Mean1} | cat - ${norm_dir}/${age}/qc_Mean.txt | sort -n | cat -n | awk '{if ($2=="'${qc_Mean1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	qc_Stdev1z=`echo $qc_Stdev1 | awk '{printf "%.2f\n", (($1-"'${qc_StdevAvg}'")/"'${qc_StdevStd}'")}'`
       	qc_Stdev1pct=`echo ${qc_Stdev1} | cat - ${norm_dir}/${age}/qc_Stdev.txt | sort -n | cat -n | awk '{if ($2=="'${qc_Stdev1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	qc_sSNR1z=`echo $qc_sSNR1 | awk '{printf "%.2f\n", (($1-"'${qc_sSNRAvg}'")/"'${qc_sSNRStd}'")}'`
       	qc_sSNR1pct=`echo ${qc_sSNR1} | cat - ${norm_dir}/${age}/qc_sSNR.txt | sort -n | cat -n | awk '{if ($2=="'${qc_sSNR1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_mean1z=`echo $mot_rel_xyz_mean1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_meanAvg}'")/"'${mot_rel_xyz_meanStd}'")}'`
       	mot_rel_xyz_mean1pct=`echo ${mot_rel_xyz_mean1} | cat - ${norm_dir}/${age}/mot_rel_xyz_mean.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_mean1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_sd1z=`echo $mot_rel_xyz_sd1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_sdAvg}'")/"'${mot_rel_xyz_sdStd}'")}'`
       	mot_rel_xyz_sd1pct=`echo ${mot_rel_xyz_sd1} | cat - ${norm_dir}/${age}/mot_rel_xyz_sd.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_sd1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_max1z=`echo $mot_rel_xyz_max1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_maxAvg}'")/"'${mot_rel_xyz_maxStd}'")}'`
       	mot_rel_xyz_max1pct=`echo ${mot_rel_xyz_max1} | cat - ${norm_dir}/${age}/mot_rel_xyz_max.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_max1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`
       	mot_rel_xyz_1mm1z=`echo $mot_rel_xyz_1mm1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_1mmAvg}'")/"'${mot_rel_xyz_1mmStd}'")}'`
       	mot_rel_xyz_1mm1pct=`echo ${mot_rel_xyz_1mm1} | cat - ${norm_dir}/${age}/mot_rel_xyz_1mm.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_1mm1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

       	mot_rel_xyz_5mm1z=`echo $mot_rel_xyz_5mm1 | awk '{printf "%.2f\n", (($1-"'${mot_rel_xyz_5mmAvg}'")/"'${mot_rel_xyz_5mmStd}'")}'`
       	mot_rel_xyz_5mm1pct=`echo ${mot_rel_xyz_5mm1} | cat - ${norm_dir}/${age}/mot_rel_xyz_5mm.txt | sort -n | cat -n | awk '{if ($2=="'${mot_rel_xyz_5mm1}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`
       	echo "QCmean ${qc_Mean1} ${qc_Mean1pct} -1 -1" >> ${extqct}
       	echo "QCstd ${qc_Stdev1} ${qc_Stdev1pct} -1 -1" >> ${extqct}
       	echo "QCsSNR ${qc_sSNR1} ${qc_sSNR1pct} -1 -1" >> ${extqct}
       	echo "mot_rel_xyz_mean ${mot_rel_xyz_mean1} ${mot_rel_xyz_mean1pct} -1 -1" >> ${extqct}
       	echo "mot_rel_xyz_sd ${mot_rel_xyz_sd1} ${mot_rel_xyz_sd1pct} -1 -1" >> ${extqct}
       	echo "mot_rel_xyz_max ${mot_rel_xyz_max1} ${mot_rel_xyz_max1pct} -1 -1" >> ${extqct}
       	echo "mot_rel_xyz_1mm ${mot_rel_xyz_1mm1} ${mot_rel_xyz_1mm1pct} -1 -1" >> ${extqct}
       	echo "mot_rel_xyz_5mm ${mot_rel_xyz_5mm1} ${mot_rel_xyz_5mm1pct} -1 -1" >> ${extqct}

fi

exit 0
