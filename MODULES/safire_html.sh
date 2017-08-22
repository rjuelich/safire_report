#!/bin/bash
############################
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
commons="${SCRIPT_DIR}/commons"
##############################
csv=$1

session=`grep -i SessionID ${csv} | awk '{print $2}'`
study_dir=`pwd`

session_dir=${study_dir}/${session}
outdir=${session_dir}/qc/INDIV_MAPS

psf_html="${SCRIPT_DIR}/HTML_TEMPLATES"
gentime=`date +%c | sed 's/ /_/g'`
tail_stem="BH_indiv_corr_mat"
seqinfo=`grep -i seq ${csv} | awk '{print $2}'`



if [ ! -e ${outdir} ]
then
	egrep 'OLID|'${session}'' /eris/sbdp/Analyses/Ongur/Cohen_Ongur_170420/clin_scales_mri_processed.csv | pcut -cs , -c 1-max -t | grep -v comments | sed s,_totalscore,,g | sed s,_total,,g | awk 'NR<10{print $0} NR>=10{$3="use"; print $0}' > ${session_dir}/${session}_clin.csv

	${MODULE_DIR}/safire_xnat.sh ${case} ${xnat} ${project}
fi

cd ${outdir}

cat ${session}_htmlhdr.txt ${session}_struct_html ${session}_extqc_html ${session}_func_html > ${session}.html


convert bhighres2target.gif -resize 1164x bhighres2target.gif

if [ ! -e sbdp_logo.png ]
then 
	cp ${SCRIPT_DIR}/ICONS/sbdp_logo.png ./
fi


convert -page 552x432+0+0 ${study_dir}/${session}/qc/INDIV_MAPS/${session}_IndivMap_${session}_${tail_stem}_label.png -page +450+330 '(' ${study_dir}/${session}/qc/INDIV_MAPS/CONCAN90.png -resize 80% ')' -background white -flatten ${session}_matrix.png
sed -i 's/0000FF/00FFFF/g' ${session}.html
sed -i 's/00FFFF/5DADE2/g' ${session}.html
sed -i 's/Intracranial/ICV/g' ${session}.html
sed -i "s/<td>Vis/<td width="2%" bgcolor=#781286><\/td><td>Vis/g" ${session}.html
sed -i "s/<td>SomMot/<td width="2%" bgcolor=#4682B4><\/td><td>SomMot/g" ${session}.html
sed -i "s/<td>DorsAttn/<td width="2%" bgcolor=#00760E><\/td><td>DorsAttn/g" ${session}.html
sed -i "s/<td>VentAttn/<td width="2%" bgcolor=#C43AFA><\/td><td>VentAttn/g" ${session}.html
sed -i "s/<td>Limb/<td width="2%" bgcolor=#DCF8A4><\/td><td>Limb/g" ${session}.html
sed -i "s/<td>Sal/<td width="2%" bgcolor=#C43AFA><\/td><td>Sal/g" ${session}.html
sed -i "s/<td>Cont/<td width="2%" bgcolor=#E69422><\/td><td>Cont/g" ${session}.html
sed -i "s/<td>Default/<td width="2%" bgcolor=#CD3E4E><\/td><td>Default/g" ${session}.html
sed -i 's/Ventral-Diencephalon/Ventral-DC/g' ${session}.html
sed -i 's/FF0000/F44336/g' ${session}.html
sed -i 's/Correlation/Correlation (R)/g' ${session}.html
sed -i 's/Slope/Slope (A)/g' ${session}.html
sed -i 's/Intercept/Intercept (B)/g' ${session}.html
sed -i "s/>_</></g" ${session}.html
sed -i "s/>_: </></g" ${session}.html
sed -i 's/0066FF/5DADE2/g' ${session}.html
sed -i s/_GEN_TIME_/${gentime}/g ${session}.html
sed -i s/SubID/${session}/g ${session}.html
sed -i s/seqinfo/${seqinfo}/g ${session}.html
#wkhtmltoimage --allow `pwd` ${session}.html ${session}.png
wkhtmltopdf --minimum-font-size 12 --allow `pwd` --page-width 1200pt --page-height 1600pt ${session}.html ${session}.pdf


#rm *tmp
if [ ! -e ${study_dir}/PDF_SUMS ]
then
	mkdir ${study_dir}/PDF_SUMS
fi

cp ${session}*.pdf ${study_dir}/PDF_SUMS/
cd ${study_dir}


echo "${session} completed"

exit 0
