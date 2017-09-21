#!/bin/bash
############################
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
psf_html="${SCRIPT_DIR}/HTML_TEMPLATES"
commons="${SCRIPT_DIR}/commons"
##############################
csv=$1

session=`grep -i SessionID ${csv} | awk '{print $2}'`
study_dir=`pwd`
session_dir=${study_dir}/${session}
outdir=${session_dir}/qc/INDIV_MAPS
outstem=${outdir}/${session}_safire

#**************************************************************************
# -----------  DO NOT CHANGE BELOW THIS LINE ----
#**************************************************************************
cd ${outdir}

if [ ! -e sbdp_logo.png ]
then 
	cp ${SCRIPT_DIR}/ICONS/sbdp_logo.png ./
fi
echo "***********************************************************"
echo "             Packaging into SAFIRE "
echo "***********************************************************"
echo " 1.   Concatenating HTML segments from each pipeline."
#  CONCATENATE ALL THE HTML SEGMENTS
cat ${session}_htmlhdr.txt ${session}_struct_html ${session}_extqc_html ${session}_func_html > ${outstem}.html

if [ ! -e ${session}_matrix.png ]
then
        echo " 2.  Adding group to individual connectivity matrix"
        tail_stem="BH_indiv_corr_mat"
        convert -page 552x432+0+0 ${study_dir}/${session}/qc/INDIV_MAPS/${session}_IndivMap_${session}_${tail_stem}_label.png \
            -page +450+330 '(' ${study_dir}/${session}/qc/INDIV_MAPS/CONCAN90.png -resize 80% ')' -background white -flatten ${session}_matrix.png
else
    echo " 2.   Using existing individual-group connectivity matrix"
fi
echo " 3.   Fixing HTML formatting"

convert bhighres2target.gif -resize 1164x bhighres2target.gif

#  FIX FORMATTING IN HTML TABLES
sed -i 's/0000FF/00FFFF/g' ${outstem}.html
sed -i 's/00FFFF/5DADE2/g' ${outstem}.html
sed -i 's/Intracranial/ICV/g' ${outstem}.html
sed -i "s/<td>Vis/<td width="2%" bgcolor=#781286><\/td><td>Vis/g" ${outstem}.html
sed -i "s/<td>SomMot/<td width="2%" bgcolor=#4682B4><\/td><td>SomMot/g" ${outstem}.html
sed -i "s/<td>DorsAttn/<td width="2%" bgcolor=#00760E><\/td><td>DorsAttn/g" ${outstem}.html
sed -i "s/<td>VentAttn/<td width="2%" bgcolor=#C43AFA><\/td><td>VentAttn/g" ${outstem}.html
sed -i "s/<td>Limb/<td width="2%" bgcolor=#DCF8A4><\/td><td>Limb/g" ${outstem}.html
sed -i "s/<td>Sal/<td width="2%" bgcolor=#C43AFA><\/td><td>Sal/g" ${outstem}.html
sed -i "s/<td>Cont/<td width="2%" bgcolor=#E69422><\/td><td>Cont/g" ${outstem}.html
sed -i "s/<td>Default/<td width="2%" bgcolor=#CD3E4E><\/td><td>Default/g" ${outstem}.html
sed -i 's/Ventral-Diencephalon/Ventral-DC/g' ${outstem}.html
sed -i 's/FF0000/F44336/g' ${outstem}.html
sed -i 's/Correlation/Correlation (R)/g' ${outstem}.html
sed -i 's/Slope/Slope (A)/g' ${outstem}.html
sed -i 's/Intercept/Intercept (B)/g' ${outstem}.html
sed -i "s/>_</></g" ${outstem}.html
sed -i "s/>_: </></g" ${outstem}.html
sed -i 's/0066FF/5DADE2/g' ${outstem}.html

gentime=`date +%c | sed 's/ /_/g'`
seqinfo=`grep -i seq ${csv} | awk '{print $2}'`

echo " 4.   Replacing Placeholder fields"
# REPLACE LAST FEW PLACEHOLDER VARIABLES IN THE HTML FILE
sed -i s/SubID/${session}/g ${outstem}.html
sed -i s/_GEN_TIME_/${gentime}/g ${outstem}.html
sed -i s/seqinfo/${seqinfo}/g ${outstem}.html

#echo "Converting HTML to PNG : ${outstem}.png"
#wkhtmltoimage --allow `pwd` ${outstem}.html ${outstem}.png
echo " 5.   Converting `basename ${outstem}`.html to `basename ${outstem}`.pdf"
wkhtmltopdf --minimum-font-size 12 --allow `pwd` --page-width 1200pt --page-height 1600pt ${outstem}.html ${outstem}.pdf >/dev/null 2>&1


#rm *tmp
if [ ! -e ${study_dir}/PDF_SUMS ]
then
	mkdir ${study_dir}/PDF_SUMS
fi

cp ${session}*.pdf ${study_dir}/PDF_SUMS/
cd ${study_dir}

echo "Packaging module Complete!"
echo ""
echo "Files Generated:"
echo ""
echo "    ${outstem}.html" 
echo "    ${outstem}.pdf"
echo "" 
echo "------------------------------------------------------------------"

exit 0
