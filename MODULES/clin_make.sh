#!/bin/bash


csv=$1
study_home=$2
project=$3

scriptsdir="/eris/sbdp/GSP_Subject_Data/SCRIPTS/RC_API"
nsub=1

for mri in `awk -F , '{print $3}' ${csv}`
do
	olid=`grep ${mri} ${csv} | awk -F , '{print $2}'`
	mri_date=`echo ${mri} | awk -F _ '{print $1}' | sed 's/^\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/20\1-\2-\3/g'`
	mri_secs=`date -d ${mri_date} +%s`
	
	dx=`grep ${olid} /eris/sbdp/Data/PHOENIX/GENERAL/GENOPHENO/extensions/redcap/testcase/temp_results/diag.csv | sed 's/1000/9999/g' | sed 's/Missing/8888/g' | awk -F , '{printf "%02d\n", $2}' | sed -f /eris/sbdp/Data/PHOENIX/GENERAL/GENOPHENO/extensions/redcap/testcase/temp_results/.mapping.sed`

	if [ `echo ${dx} | awk '{print length($1)}'` -lt 1 ] && [ ${cohort} = "Patient" ]
	then
		dx=`cat ${study_home}/${olid}/redcap/${olid}_redcap_dx.csv | awk -F , '{ for (i=4; i<=NF; i++) if ($i==3) print i}' | tail -1 | sed -f ${scriptsdir}/DX_Lookup.sed -`
	fi

	#if [ `echo ${dx} | awk '{print length($1)}'` -lt 1 ] && [ ${cohort} = "Patient" ]
	#then
	#	dx=`${scriptsdir}/GenoPheno_dx_ALT_1sub.sh ${olid} | grep -A 1 scid | tail -1 | sed -f ${scriptsdir}/DX_Lookup.sed`
	#fi
	
	if [ `echo ${dx} | awk '{print length($1)}'` -lt 1 ] && [ ${cohort} = "Patient" ]
	then
		dx="`grep ${olid} /eris/sbdp/Data/PHOENIX/GENERAL/GENOPHENO/redcap/raw/GP_DX_ALT.csv | awk -F , '{print $3}' | tail -1`"
	fi
	#sex=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $5}' | sort -n | awk '{ if (length($2)>=1) print $0}' | head -1 | awk '{ if ($2=="1") print "M"; else if ($2=="2") print "F"}'`

	#age=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $6}' | sort -n | awk '{ if (length($2)>=1) print $0}' | head -1 | awk '{print $2}'`

	ymrs=`cat ${study_home}/${olid}/redcap/${olid}_redcap_scales_raw.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; for ( i=7 ; i<=17 ; i++ ) j+=$i; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $4, j; j=0 }' | sort -n | awk '{ OFS=","; if (length($3)>=1) print $3}' | head -1 | awk '{print $1}'`

#ymrs=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $7, $8, $9, $10, $11}' | sort -n | awk '{ if (length($2)>=1) print $0}' | head -1 | awk '{print $2}'`

	madrs=`cat ${study_home}/${olid}/redcap/${olid}_redcap_scales_raw.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; for ( i=18 ; i<=27 ; i++ ) j+=$i; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), j; j=0}' | sort -n | awk '{ OFS=","; if (length($2)>=1) print $2}' | head -1 | awk '{print $1}'`

#madrs=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $7, $8, $9, $10, $11}' | sort -n | awk '{ if (length($3)>=1) print $0}' | head -1 | awk '{print $3}'`

	panss=`cat ${study_home}/${olid}/redcap/${olid}_redcap_scales_raw.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; for ( i=28 ; i<=34 ; i++ ) j+=$i ; for ( a=35 ; a<=41 ; a++ ) k+=$a; for ( b=42 ; b<=57 ; b++ ) l+=$b; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), j, k, l; j=0; k=0; l=0}' | sort -n | awk '{ OFS=","; if (length($2)>=1) print $2, $3, $4}' | head -1 | awk '{OFS=","; print $1}'`

	panss_p=`echo ${panss} | awk -F , '{print $1}'`
	panss_n=`echo ${panss} | awk -F , '{print $2}'`
	panss_g=`echo ${panss} | awk -F , '{print $3}'`

	echo "YMRS ${ymrs} use" > ${study_home}/${olid}/mri/processed/fs450/${mri}/${mri}_clin.csv
	echo "MADRS ${madrs} use" >> ${study_home}/${olid}/mri/processed/fs450/${mri}/${mri}_clin.csv
	echo "PANSSp ${panss_p} use" >> ${study_home}/${olid}/mri/processed/fs450/${mri}/${mri}_clin.csv
	echo "PANSSn ${panss_n} use" >> ${study_home}/${olid}/mri/processed/fs450/${mri}/${mri}_clin.csv
	echo "PANSSg ${panss_g} use" >> ${study_home}/${olid}/mri/processed/fs450/${mri}/${mri}_clin.csv
	echo "DX ${dx}" >> ${study_home}/${olid}/mri/processed/fs450/${mri}/${mri}_clin.csv
done
