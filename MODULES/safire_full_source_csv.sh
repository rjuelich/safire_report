# Generates the csv that should be used to create html cover page

study="/eris/sbdp/Data/Ongur/GenoPheno"
targetfullcsv="/eris/sbdp/Analyses/Ongur/Cohen_Ongur_latest/Cohen_Ongur_GenoPheno_mri.csv"

cd $study

for sub in `ls -1`
do 
	for mri in `ls -1 ${sub}/mri/processed/fs450 | grep _FS$ | sed 's/_FS//g'`
	do header="OLID,MRIID"
		val="${sub},${mri}"
		for roi in `awk '{print $1}' ${sub}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt`
		do 
			if [ -e ${sub}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt ] && [ `grep -w ${roi} ${sub}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{print NF}'` -gt 3 ]
			then 
				header="${header},L_${roi},R_${roi}"
				roip=`grep -w ${roi} ${sub}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{OFS=","; printf "%.2f,%.2f\n", $3, $5}'`
				val="${val},${roip}"
			elif [ -e ${sub}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt ] && [ `grep -w ${roi} ${sub}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{print NF}'` -le 3 ]
			then 
				header="${header},${roi}"
				roip=`grep -w ${roi} ${sub}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{OFS=","; printf "%.2f\n", $3}'`
				val="${val},${roip}"
			fi
		done
		echo ${header}  >> $targetfullcsv
		echo ${val}  >> $targetfullcsv
	done
done

cp $targetfullcsv temp.csv

head -1 temp.csv > $targetfullcsv

cat temp.csv | grep -v OLID >> $targetfullcsv

rm temp.csv
