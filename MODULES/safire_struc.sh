#!/bin/sh
#
#  Is designed to run only what has not already completed on each case
#  
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"

#**************************************************************************
# -----------  DO NOT CHANGE BELOW THIS LINE ----
#**************************************************************************


csv=$1
study=`grep -i project ${csv} | awk '{print $2}'`
xnat=`grep -i xnat ${csv} | awk '{print $2}'`
age=`grep -i age ${csv} | awk '{print $2}'`
sex=`grep -i sex ${csv} | awk '{print $2}'`
race=`grep -i race ${csv} | awk '{print $2}'`
tr=`grep -i tr ${csv} | awk '{print $2}'`
dx=`grep -i DX ${csv} | awk '{print $2}' | tail -1`
studyID=`grep -i studyID ${csv} | awk '{print $2}'`
seqinfo=`grep -i seq ${csv} | awk '{print $2}'`
sub=`grep -i SubID ${csv} | awk '{print $2}'`
case=${sub}
study_dir=`pwd`

tail_stem="BH_indiv_corr_mat"
psf_html="${SCRIPT_DIR}/HTML_TEMPLATES"
datestr=`date +%y%m%d_%H%M`
summlog="${study_dir}/${sub}/${sub}_psfsummary_${datestr}.log"


case_dir=${study_dir}/$case
fs_dir=${study_dir}/${case}_FS
outdir=${case_dir}/qc/INDIV_MAPS

# better to use recon-all.log for freesurfer version
fsvers=`grep -i "Actual FREESURFER_HOME" ${study_dir}/${case}_FS/scripts/recon-all.log | tail -1 | awk -F / '{print $NF}' | tail -1`
#fsvers=`grep -i freesurfer_home ${case_dir}/logs/fcMRI.log | awk '{print $2}' | awk -F / '{print $NF}' | tail -1`
avg152T1_brain_path="`which fsl | sed 's/bin\/fsl/data\/standard\/avg152T1_brain/g'`"
#avg152T1_brain_path="/cluster/nrg/tools/0.10.0b/apps/arch/linux_x86_64/fsl/4.1.7/data/standard/avg152T1_brain"
summlog="${study_dir}/${case}/${case}_safire_${datestr}.log"
sdir=${outdir}


age0=`echo ${age} | cut -c 1 | awk '{print $1"0"}'`
bsvnorms="${SCRIPT_DIR}/NORMS/BSV"
nsubs=`cat ${bsvnorms}/${age0}/${age0}s.txt | uniq | wc -l | awk '{print $1+2}'`
bsvt=${sdir}/${sub}_bsv_table.txt


echo ""
echo "***********************************************************"
echo "             Computing STRUCTURAL MEASURES "
echo "***********************************************************"
echo " 1.   Generating T1 snapshots "
SUBJECTS_DIR=`pwd`

# This may not be getting used at all or may be in the "Functional Measures"
if [ ! -e ${sdir}/bhighres2target.gif ]
then
    # Subject T1 over MNI average T1	
	cd ${study_dir}/${sub}/qc
	slicer bhighres2target ${avg152T1_brain_path} -s 1 -x 0.45 sla -x 0.65 slb -y 0.45 slc -y 0.65 sld -z 0.45 sle -z 0.65 slf >> ${summlog}

	convert -colors 100 -background black +append sla slb slc sld sle slf -resize 1164x ${sdir}/bhighres2target.gif
	rm s*
	cd ${study_dir}
fi

echo " 2.   Generating FS surface snapshots (FS $fsvers)"
if [ ! -e ${sdir}/${sub}_fs_surfs.png ]
then
	if [ `ls ${study_dir}/${sub}_FS/tmp/infl_lh_lat.tif | wc -w` -lt 1 ] 
    then
        gen_surfaces ${sub}
    fi 
	cd ${study_dir}/${sub}_FS/tmp
	convert '(' infl_lh_lat.tif -crop 570x400+15+100 ')' '(' infl_rh_lat.tif -crop 570x400+15+100 ')' '(' infl_lh_med.tif -crop 570x400+15+100 ')' '(' infl_rh_med.tif -crop 570x400+15+100 ')' +append -resize 1164x ${sdir}/${sub}_fs_surfs.png
	cd ${study_dir}

fi

#  UPDATE below based on actual name of combined sections
echo " 3.   Generating FS volumetric snapshots "
if [ ! -e ${sdir}/${sub}_fs_slices.png ]
then
	if [ `ls ${study_dir}/${sub}_FS/tmp/*axial*tif | wc -w` -lt 1 ] 
    then
	    sed s/__SESSID__/${sub}_FS/g ${SCRIPT_DIR}/commons/tkmedit_6sl.tcl_template > tkmedit_6sl.tcl
	    gen_fs_images ${sub}
    fi 

	cd ${study_dir}/${sub}_FS/tmp
	convert ${sub}_FS_sagittal_2.tif ${sub}_FS_axial_2.tif ${sub}_FS_coronal_2.tif +append -resize 1164x -fill white -pointsize 24 -gravity northwest -draw "text 5,5 'Individual Subject Segmentation and Cortical Surface (FreeSurfer ${fsvers})'" ${sdir}/${sub}_fs_slices.png
	cd ${study_dir} 
fi

cd $study_dir
echo " 4.   Computing Age-normalized FS statistics"

# Finally run through the Age-normalized Z values for all FS stats and create a table
if [ ! -e ${sub}_FS/stats/${sub}_fssum.txt ]
then
	echo "parsing freesurfer stats"
	${SCRIPT_DIR}/commons/fs_parse_stats.sh ${sub} ${age} >> ${summlog}   
fi

cp ${sub}_FS/stats/${sub}_fssum* ${sdir}/

###### new html gen steps

ICV=`grep -w ICV ${sdir}/${sub}_fssum.txt | awk '{printf "%.2f\n", $2/1000}'`
icvz=`grep -w ICV ${sdir}/${sub}_fssum_table.txt | awk '{printf "%.2f\n", $2}'`
icvp=`grep -w ICV ${sdir}/${sub}_fssum_table.txt | awk '{printf "%.2f\n", $3}'`

echo "ICV ${ICV} ${icvz} ${icvp}" > ${sdir}/${sub}_ICV_table.txt

vent=`grep Ventricles-All ${sdir}/${sub}_fssum.txt | head -1 | awk '{print $2}'`
ventz=`grep Ventricles-All ${sdir}/${sub}_fssum.txt | tail -1 | awk '{print $2}'`
ventp=`grep Ventricles-All ${sdir}/${sub}_fssum.txt | tail -1 | awk '{print $3}'`

echo "Ventricles-All ${vent} ${ventz} ${ventp}" > ${sdir}/${sub}_Ventricles-All_table.txt


if [ -e ${bsvt} ]
then
	rm ${bsvt}
fi

### Get n2642 sample mean/std

bsvm=`awk '{sum+=$1}END{print sum/NR}' ${bsvnorms}/${age0}/BSV.txt`
bsvstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${bsvnorms}/${age0}/BSV.txt`

vbrm=`awk '{sum+=$1}END{print sum/NR}' ${bsvnorms}/${age0}/VBR.txt`
vbrstd=`awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt((sumsq/NR) - (sum/NR)**2)}' ${bsvnorms}/${age0}/VBR.txt`

bsvval=`grep "Brain Segmentation Volume" ${sub}_FS/stats/aseg.stats | grep -v Ventricles | awk -F , '{printf "%d\n", $4}'`
bsvnvval=`grep "Brain Segmentation Volume" ${sub}_FS/stats/aseg.stats | grep Ventricles | grep -v Surf | awk -F , '{printf "%d\n", $4}'`
vbrval=`echo "${bsvnvval} ${bsvval}" | awk '{printf "%f\n", ($2-$1)/$2}'`

bsvz=`echo ${bsvval} | awk '{printf "%.2f\n", (($1-"'${bsvm}'")/"'${bsvstd}'")}'`
bsvpct=`echo ${bsvval} | cat - ${bsvnorms}/${age0}/BSV.txt | sort -n | cat -n | awk '{if ($2=="'${bsvval}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`


vbrz=`echo ${vbrval} | awk '{printf "%.2f\n", (($1-"'${vbrm}'")/"'${vbrstd}'")}'`
vbrpct=`echo ${vbrval} | cat - ${bsvnorms}/${age0}/VBR.txt | sort -n | cat -n | awk '{if ($2=="'${vbrval}'") print $1}' | tail -1 | awk '{printf "%.1f\n", (($1/"'${nsubs}'")*100)-0.01}'`

echo "BSV ${bsvval} ${bsvz} ${bsvpct}" > ${bsvt}
echo "VBR ${vbrval} ${vbrz} ${vbrpct}" >> ${bsvt}


if [ -e ${sdir}/${sub}_struct_html ]
then
	rm ${sdir}/${sub}_struct_html
fi

cp ${psf_html}/struct_htmlhdr.txt ${sdir}/${sub}_struct_html

${SCRIPT_DIR}/commons/html_tabler_4col_Rlow.sh `cat ${sdir}/${sub}_ICV_table.txt` >> ${sdir}/${sub}_struct_html
${SCRIPT_DIR}/commons/html_tabler_4col_Rlow.sh `grep BSV ${bsvt}` >> ${sdir}/${sub}_struct_html
${SCRIPT_DIR}/commons/html_tabler_4col_Rhigh.sh `grep VBR ${bsvt}` >> ${sdir}/${sub}_struct_html
${SCRIPT_DIR}/commons/html_tabler_4col_Rhigh.sh `cat ${sdir}/${sub}_Ventricles-All_table.txt` >> ${sdir}/${sub}_struct_html

cat ${psf_html}/aseghd.txt >> ${sdir}/${sub}_struct_html

# consider renaming broi and groi to fsroi and outroi
for broi in `awk -F , '{print $1}' ${psf_html}/asROItrans.txt`
do
	for groi in `grep -w ${broi} ${psf_html}/asROItrans.txt | awk -F , '{print $2}'`
	do
		${SCRIPT_DIR}/commons/html_tabler_5col.sh `grep -w ${broi} ${sdir}/${sub}_fssum_table.txt | sed s/${broi}/${groi}/g | awk '{printf "%s %.2f %d %.2f %d\n", $1, $2, $3, $4, $5}'` ; done >> ${sdir}/${sub}_struct_html
done

cat ${psf_html}/aparchd.txt >> ${sdir}/${sub}_struct_html

for broi in `awk -F , '{print $1}' ${psf_html}/apROItrans.txt`
do
	for groi in `grep -w ${broi} ${psf_html}/apROItrans.txt | awk -F , '{print $2}'`
	do
		${SCRIPT_DIR}/commons/html_tabler_5col.sh `grep -w ${broi} ${sdir}/${sub}_fssum_table.txt | sed s/${broi}/${groi}/g | awk '{printf "%s %.2f %d %.2f %d\n", $1, $2, $3, $4, $5}'` ; done >> ${sdir}/${sub}_struct_html
done

echo "</table>" >> ${sdir}/${sub}_struct_html
echo "</td>" >> ${sdir}/${sub}_struct_html
echo "</tr>" >> ${sdir}/${sub}_struct_html


echo "Structural module complete!"

