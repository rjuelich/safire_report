#!/bin/bash
#
# Generates the csv that should be used to create html cover page
#
# 
#
#

SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
commons="${SCRIPT_DIR}/commons"

if [ $# -lt 1 ]
then
	echo "Id: safire_full_source_csv.sh,v 2017/08/22 eag66 Exp $"
        echo "Usage: safire_full_source_csv.sh <study_dir> <study> <target_dir> <target_csv_stem>"
	exit
fi

data_dir=$1
study=$2
target_dir=$3
target_csv_stem=$4

# sample call to script
# safire_full_source_csv.sh "/eris/sbdp/Data/Ongur/GenoPheno" GenoPheno "/eris/sbdp/Analyses/Ongur/Cohen_Ongur_latest" Cohen_Ongur_GenoPheno
# ./safire_full_source_csv.sh "/eris/ressler/Data" DD "/eris/ressler/Data" "Ressler_DD" 

targetmricsv=${target_csv_stem}"_mri.csv"

cd $data_dir

for sub in `ls -1 | grep M$`
do
	if [ ${study} = "GenoPheno" ]
	then
		mri_dir="${sub}/mri/processed/fs450"
	else
		mri_dir="${sub}/mri"
	fi
	for mri in `ls -1 ${mri_dir} | grep _FS$ | sed 's/_FS//g'`
	do 
		header="OLID,MRIID"
		val="${sub},${mri}"
		mri_path="${mri_dir}/${mri}"
		for roi in `awk '{print $1}' ${mri_path}/qc/INDIV_MAPS/${mri}_fssum_table.txt`
		do 
			if [ -e ${mri_path}/qc/INDIV_MAPS/${mri}_fssum_table.txt ] && [ `grep -w ${roi} ${mri_path}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{print NF}'` -gt 3 ]
			then 
				header="${header},L_${roi},R_${roi}"
				roip=`grep -w ${roi} ${mri_path}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{OFS=","; printf "%.2f,%.2f\n", $3, $5}'`
				val="${val},${roip}"
			elif [ -e ${mri_path}/qc/INDIV_MAPS/${mri}_fssum_table.txt ] && [ `grep -w ${roi} ${mri_path}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{print NF}'` -le 3 ]
			then 
				header="${header},${roi}"
				roip=`grep -w ${roi} ${mri_path}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{OFS=","; printf "%.2f\n", $3}'`
				val="${val},${roip}"
			fi
		done
		echo ${header}  >> $targetmricsv
		echo ${val}  >> $targetmricsv
	done
done

cp $targetmricsv temp.csv

head -1 temp.csv > $targetmricsv

cat temp.csv | grep -v OLID >> $targetmricsv

rm temp.csv
