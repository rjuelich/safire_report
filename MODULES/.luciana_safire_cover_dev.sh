#!/bin/bash

csv=$1
study_home=$2

scriptsdir="/eris/sbdp/GSP_Subject_Data/SCRIPTS/RC_API"
nsub=1


for olid in `awk -F , '{print $1}' ${csv} | sort | uniq`
do
	${scriptsdir}/GenoPheno_cohort_1sub.sh ${olid} > ${study_home}/${olid}/redcap/${olid}_redcap_cohort.csv
	${scriptsdir}/GenoPheno_dx_1sub.sh ${olid} > ${study_home}/${olid}/redcap/${olid}_redcap_dx.csv
	${scriptsdir}/GenoPheno_CoverInfo_1sub.sh ${olid} > ${study_home}/${olid}/redcap/${olid}_demos_scales.csv
done

cat /eris/sbdp/Analyses/Ongur/Cohen_Ongur_170420/cp_template.html

echo ""
echo ""
echo ""

for mri in `awk -F , '{print $2}' ${csv}`
do
	mri_date=`echo ${mri} | awk -F _ '{print $1}' | sed 's/^\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/20\1-\2-\3/g'`
	mri_secs=`date -d ${mri_date} +%s`

	olid=`grep ${mri} ${csv} | awk -F , '{print $1}'`
	cohort=`cat ${study_home}/${olid}/redcap/${olid}_redcap_cohort.csv | grep [1-3]$ | awk -F , '{ if ($3=="1") print "Patient"; else if ($3=="2") print "Control"; else if ($3=="3") print "Relative"}' | sort | uniq | paste -s -d \; -`
	dx=`cat ${study_home}/${olid}/redcap/${olid}_redcap_dx.csv | awk -F , '{ for (i=4; i<=NF; i++) if ($i==3) print i}' | sort -n | uniq | sed -f ${scriptsdir}/DX_Lookup.sed -`
	
	age=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $6}' | sort -n | awk '{ if (length($2)>=1) print $0}' | head -1 | awk '{ if ($2=="1") print "Male"; else if ($2=="2") print "Female"}'`

	sex=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $5}' | sort -n | awk '{ if (length($2)>=1) print $0}' | head -1 | awk '{print $2}'`
	#age=`${scriptsdir}/GenoPheno_CoverInfo_1sub.sh ${olid} | grep ${mri} | awk -F , '{print $6}'`	
	#sex=`${scriptsdir}/GenoPheno_CoverInfo_1sub.sh ${olid} | grep ${mri} | awk -F , '{if ($5=="1") print "Male"; else if ($5=="2") print "Female"}'`	

	demos=`echo ${cohort},${dx},${age},${sex}`

	
	
	ymrs=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $7, $8, $9, $10, $11}' | sort -n | awk '{ if (length($2)>=1) print $0}' | head -1 | awk '{print $2}'`

	madrs=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $7, $8, $9, $10, $11}' | sort -n | awk '{ if (length($3)>=1) print $0}' | head -1 | awk '{print $3}'`

	panss=`cat ${study_home}/${olid}/redcap/${olid}_demos_scales.csv | awk -F , 'NR>1 {"date -d \""$4"\" +%s" | getline dt; print sqrt((dt-"'${mri_secs}'")*(dt-"'${mri_secs}'")), $7, $8, $9, $10, $11}' | sort -n | awk '{ if (length($4)>=1) print $0}' | head -1 | awk '{OFS=","; print $4, $5, $6}'`

	scales=`echo ${ymrs},${madrs},${panss}`

	

	lsfg=`grep superiorfrontal ${study_home}/${olid}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{printf "%.1f\n", $3}'`
	rsfg=`grep superiorfrontal ${study_home}/${olid}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_fssum_table.txt | awk '{printf "%.1f\n", $5}'`
	vbr=`grep VBR ${olid}/mri/processed/fs450/${mri}/qc/INDIV_MAPS/${mri}_bsv_table.txt | awk '{printf "%.4f,%.1f\n", $2, $4}'`

	echo '<tr width="100%" style="page-break-inside: avoid;"><td align=center>'${nsub}'</td><td align=center>'${olid}'</td><td align=center><a href='PDFs/${mri}.pdf'>'${mri}'</a></td>'
	
	echo ${demos} | awk -F , '{OFS=""; print "<td align=center width=6.5%>", $1, "</td>", "<td align=center width=6.5%>", $2, "</td>", "<td align=center width=6.5%>", $3, "</td>", "<td align=center width=6.5%>", $4, "</td>"}'

	echo ${scales} | awk -F , '{OFS=""; print "<td align=center width=5%>", $1, "</td>", "<td align=center width=5%>", $2, "</td>", "<td align=center width=5%>", $3, "</td>", "<td align=center width=5%>", $4, "</td>", "<td align=center width=5%>", $5, "</td>"}'

	if [ `echo ${vbr} | awk -F , '{ if ($2>=95) print 2; else print 0}'` -gt 1 ]
	then
		echo ${vbr} | awk -F , '{OFS=""; print "<td align=center width=7.5% bgcolor=#F44336>", $1, "</td>", "<td align=center width=7.5% bgcolor=#F44336>", $2, "</td>"}'
	else
		echo ${vbr} | awk -F , '{OFS=""; print "<td align=center width=7.5%>", $1, "</td>", "<td align=center width=7.5%>", $2, "</td>"}'
	fi

	if [ `echo ${lsfg} | awk -F , '{ if ($1<=5) print 2; else print 0}'` -gt 1 ]
	then
		echo ${lsfg} | awk -F , '{OFS=""; print "<td align=center width=7.5% bgcolor=#F44336>", $1, "</td>"}'
	else
		echo ${lsfg} | awk -F , '{OFS=""; print "<td align=center width=7.5%>", $1, "</td>"}'
	fi

	if [ `echo ${rsfg} | awk -F , '{ if ($1<=5) print 2; else print 0}'` -gt 1 ]
	then
		echo ${rsfg} | awk -F , '{OFS=""; print "<td align=center width=6.5% bgcolor=#F44336>", $1, "</td>"}'
	else
		echo ${rsfg} | awk -F , '{OFS=""; print "<td align=center width=6.5%>", $1, "</td>"}'
	fi
	
	echo "</tr>"

	nsub=`expr $nsub + 1`
	
#	if [ ${nsub} = 67 ] || [ ${nsub} = 135 ] || [ ${nsub} = 204 ] || [ ${nsub} = 271 ] || [ ${nsub} = 339 ] || [ ${nsub} = 404 ] || [ ${nsub} = 480 ]
#	then
#		echo "</table>"
#		echo ""
#		echo ""
#		echo '<table class="TFtable" border="1" cellspacing="0" cellpadding="2" width="1200px" style="border-collapse: collapse; margin:auto;">'
#		
#		echo '<tr width="100%"><th bgcolor=#999999 width="2%">#</th><th bgcolor=#999999 width="6.5%">OLID</th><th bgcolor=#999999 width="10%">MCLID</th><th colspan=4 bgcolor=#999999 width="25%">Demographics</th><th colspan=5 bgcolor=#999999 width="25%">Clinical Scales</th><th bgcolor=#999999 colspan=2 width="15%">VBR</th><th bgcolor=#999999 colspan=2 width="15%">SFG Thickness</th></tr>'
#
#		echo '<tr width="100%"><td bgcolor=#999999 width="2%"></td><td bgcolor=#999999 width="6.5%"></td><td bgcolor=#999999 width="10%"></td><td align=center bgcolor=#999999 width="6.5%">Cohort</td><td bgcolor=#999999 align=center width="6.5%">DX</td><td bgcolor=#999999 align=center width="6.5%">Age</td><td bgcolor=#999999 align=center width="6.5%">Sex</td><td align=center bgcolor=#999999 width="5%">YMRS</td><td bgcolor=#999999 align=center width="5%">MADRS</td><td bgcolor=#999999 align=center width="5%">PANSS+</td><td bgcolor=#999999 align=center width="5%">PANSS-</td><td bgcolor=#999999 align=center width="5%">PANSSg</td><td bgcolor=#999999 align=center width="7.5%">Raw</td><td bgcolor=#999999 align=center width="7.5%">%-ile</td><td bgcolor=#999999 align=center width="7.5%">LH %</td><td bgcolor=#999999 align=center width="7.5%">RH %</td></tr>'
#
#	fi


done

echo "</table>"
echo "</body>"
echo "</html>"
