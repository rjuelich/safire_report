#!/bin/sh
#
#  Is designed to run only what has not already completed on each session
#  
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
commons="${SCRIPT_DIR}/commons"
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
dx=`grep -i DX ${csv} | awk '{print $2}'`
studyID=`grep -i "studyID" ${csv} | awk '{print $2}'`
seqinfo=`grep -i seq ${csv} | awk '{print $2}'`
session=`grep -i SubID ${csv} | awk '{print $2}'`
session=${session}
tail_stem="BH_indiv_corr_mat"
study_dir=`pwd`
psf_html="${SCRIPT_DIR}/HTML_TEMPLATES"
datestr=`date +%y%m%d_%H%M`
summlog="${study_dir}/${session}/${session}_psfsummary_${datestr}.log"


session_dir=${study_dir}/${session}
fs_dir=${study_dir}/${session}_FS
outdir=${session_dir}/qc/INDIV_MAPS
fsvers=`grep -i "actual FREESURFER_HOME" ${study_dir}/${session}_FS/scripts/recon-all.log | tail -1 | awk '{print $2}'`
avg152T1_brain_path="`which fsl | sed 's/bin\/fsl/data\/standard\/avg152T1_brain/g'`"
summlog="${study_dir}/${session}/${session}_safire_${datestr}.log"

target_stem="safire_func"

echo ""
echo "***********************************************************"
echo "             Computing FUNCTIONAL MEASURES "
echo "***********************************************************"
echo " 1.   Generating EPI snapshots "
if [ ! -e ${outdir}/example_func2bhighres.gif ]
then
        cd ${study_dir}/${session}/qc

        slicer example_func2target bhighres2target -s 1 -x 0.45 sla -x 0.65 slb -y 0.45 slc -y 0.65 sld -z 0.45 sle -z 0.65 slf >> ${summlog}

        convert -colors 100 -background black +append sla slb slc sld sle slf -resize 1164x ${outdir}/example_func2bhighres.gif
        rm s*
	cd ${study_dir}
fi

echo " 2.   Compiling Motion Plots "
# Convert MCFLIRT output to PNG

cd ${outdir}

convert ${study_dir}/${session}/qc/mc_disp.gif mc_disp.png
convert ${study_dir}/${session}/qc/mc_rot.gif mc_rot.png
convert ${study_dir}/${session}/qc/mc_trans.gif mc_trans.png

cd ${study_dir}

echo " 3.   Creating individual fcMRI adjacency matrix."
if [ ! -e ${study_dir}/${session}/qc/INDIV_MAPS/${session}_IndivMap_${session}_${tail_stem}_label.png ]
then
	# Copy all scripts to the study directory 
	if [ ! -e ${study_dir}/PlotCorrMatrix.m ]
	then
	    cp ${commons}/PlotCorrMatrix.m ./ 
	    cp ${commons}/PlotFullMean_Indiv_130530.m ./
	    cp ${commons}/ProcSurfFast_PlotFullMeanCorr_Indiv_150417.py ./   # Create individual grids
	fi

	if [ ! -e ${session}_IndivMap.csv ]
	then
		echo "${session},1" >> ${session}_IndivMap.csv
		echo "${session},1" >> ${session}_IndivMap.csv
	fi
	
	./ProcSurfFast_PlotFullMeanCorr_Indiv_150417.py -s ${session}_IndivMap.csv -o ${outdir}/ -p 1.301 -noCov >> ${summlog}

	cd ${study_dir}/${session}/qc/INDIV_MAPS
	
	# Label and resize Indiv fcMRI Matrix	
	convert ${session}_IndivMap_${session}_${tail_stem}.eps ${session}_IndivMap_${session}_${tail_stem}.png
	convert ${session}_IndivMap_${session}_${tail_stem}.png -background white -gravity NorthWest -stroke black \
		-fill black -pointsize 18 -strokewidth 1 -gravity NorthWest \
		-draw "fill black text 0,0 'Connectivity'" -draw "fill black text 0,20 'Matrix'" \
		-gravity South -draw "text -25,+25 'L'" -draw "text +25,+25 'R'" -scale x432 ${session}_IndivMap_${session}_${tail_stem}_label.png

    convert -page 552x432+0+0 ${study_dir}/${session}/qc/INDIV_MAPS/${session}_IndivMap_${session}_${tail_stem}_label.png \
        -page +450+330 '(' ${SCRIPT_DIR}/ICONS/CONCAN90.png -resize 80% ')' -background white -flatten ${session}_matrix.png

	if [ -e ${study_dir}/${session}_IndivMap.csv ]
	then
		rm ${study_dir}/${session}_IndivMap.csv
	fi
fi
#**************************************************************** 
#  Parse the individual fcMRI correlation matrix
#**************************************************************** 

cd $outdir

echo " 4.   Creating individual-to-group functional connectivity scatterplot."
if [ ! -e  ${session}_scatter_label.png ]
then
	if [ ! -e PlotIndiv2Group.sh ]
	then 
		cp ${commons}/PlotIndiv2Group* ./
		cp ${SCRIPT_DIR}/commons/SumGen.m ./
		cp ${SCRIPT_DIR}/ICONS/CONCAN90.png ./
		cp ${SCRIPT_DIR}/commons/parse_matrix2* ./
		cp ${SCRIPT_DIR}/commons/cell2csv.m ./
		cp ${SCRIPT_DIR}/ICONS/legend2.png ./
		cp ${SCRIPT_DIR}/ICONS/leg1.png ./
	fi

	# Create scatter between individual and group level fCMRI matrices
	./PlotIndiv2Group.sh ${session}_IndivMap_${session}_${tail_stem}.txt ${session}_scatter >> ${summlog}

	# Label and resize scatter
	convert ${session}_scatter.png -gravity NorthWest -background transparent -fill white \
		-draw 'rectangle 80,35 170,105' -fill black -gravity SouthWest -pointsize 12 \
		-draw "fill black text 120,370 'R = `awk -F , '{printf "%.2f\n", $1}' ${session}_scatter.csv`'" \
		-draw "fill black text 120,350 'A = `awk -F , '{printf "%.2f\n", $2}' ${session}_scatter.csv`'"  \
		-draw "fill black text 120,330 'B = `awk -F , '{print $3}' ${session}_scatter.csv`'" \
		-draw "fill black text 120,310 'Y = A(x) + B'" -scale 900x ${session}_scatter_label.png


convert bhighres2target.gif -resize 1164x bhighres2target.gif

fi

echo " 5.   Computing Age-normalized mean network connectivity."
if [ ! -e ${session}_17net_table.txt ]
then
        # Compute within-network mean and SD for each network
        if [ ! -e ${session}_parsed.txt ]; then
     #       echo ${SCRIPT_DIR}/commons/parse_matrix2.sh ${session}_IndivMap_${session}_${tail_stem}.txt ${session}_parsed.txt 
            ${SCRIPT_DIR}/commons/parse_matrix2.sh ${session}_IndivMap_${session}_${tail_stem}.txt ${session}_parsed.txt >> ${summlog}
        fi

        #  NB: Do we really need to create these?
        for net in `cat ${psf_html}/NetNames_orig.txt`
        do
            rm -f ${session}_${net}.txt
            grep ${net} ${session}_parsed.txt | awk -F , '{print $2}' >> ${session}_${net}.txt
        done

	#echo ${SCRIPT_DIR}/commons/func_tabler.sh ${session} ${age} ${study_dir}
	${SCRIPT_DIR}/commons/func_tabler.sh ${session} ${age} ${study_dir}
fi

cd ${study_dir}
${SCRIPT_DIR}/commons/func_tabler.sh ${session} ${age} ${study_dir}


echo " 6.   Computing Age-normalized QC Measures."
if [ ! -e ${outdir}/${session}_qc_table.txt ]
then
        # Extract mean slice SNR from stackcheck report files
        if [ ! -e ${session}.snr.txt ]
        then
                for snr in `ls -1 ${study_dir}/${session}/qc/*rest.report`
                do
                    tail -1 ${snr} >> tmp_snr
                done 
                cat tmp_snr | awk '{print "SNR"NR":", $5}' >> ${session}.snr.txt
		        cp ${session}.snr.txt SNR.txt
        fi

        ${commons}/qctabler.sh ${session} ${age} ${study_dir}
fi

cd ${study_dir}
${commons}/qctabler.sh ${session} ${age} ${study_dir}

cd ${study_dir}

${commons}/17nethtml_wrap.sh ${session}
if [ -e ${session}/qc/INDIV_MAPS/${session}_qchtml.tmp ]
then
	rm ${session}/qc/INDIV_MAPS/${session}_qchtml.tmp
fi

for val in Correlation Slope Intercept
do
	${commons}/func_qc_html.sh `grep ${val} ${session}/qc/INDIV_MAPS/${session}_qc_table.txt | awk '{print $1, $2, $3, $4, "'${session}'"}'`
done

if [ -e ${study_dir}/${session}/qc/INDIV_MAPS/${session}_extqc_htmlt ]
then
	rm ${study_dir}/${session}/qc/INDIV_MAPS/${session}_extqc_htmlt
fi

if [ -e ${study_dir}/${session}/${session}_extqc_table.txt ]
then
	rm ${study_dir}/${session}/${session}_extqc_table.txt
fi

${commons}/extqc_tabler.sh ${session} ${age} ${study_dir}

for roi in `awk '{print $1}' ${study_dir}/${session}/${session}_extqc_table.txt`
do
	if [ -e ${study_dir}/${session}/qc/extended-qc ]
	then
		${commons}/extqc_htmlgen.sh `grep ${roi} ${study_dir}/${session}/${session}_extqc_table.txt` >> ${study_dir}/${session}/qc/INDIV_MAPS/${session}_extqc_htmlt
	else
		cp ${psf_html}/extqc_null_html ${study_dir}/${session}/qc/INDIV_MAPS/${session}_extqc_htmlt
	fi
done

cat ${psf_html}/extqc_html.hdr ${outdir}/${session}_extqc_htmlt > ${outdir}/${session}_extqc_html
cat ${psf_html}/qc_htmlheader.txt ${outdir}/${session}_qchtml.tmp ${psf_html}/17netIMGs.htmlhd ${outdir}/${session}_17nethtml.txt ${psf_html}/htmltail.txt > ${outdir}/${session}_func_html
sed -i 's/seqinfo/${seqinfo}/g' ${outdir}/${session}_func_html


echo " 7.   Creating csv file."
if [  -e ${outdir}/${session}_17net_table.txt ]
then
	echo “creating csv from functional connectivity network statistics”
        cat ${outdir}/${session}_17net_table.txt | cut -f 1 -d " " | awk '{OFS=","; printf "%s,%s_prcnt,",$1,$1}'  > ${outdir}/${target_stem}.csv
        cat ${outdir}/${session}_17net_table.txt | cut -f 2,3 -d " " | awk '{OFS=","; printf "%.2f,%.2f,",$1,$2}' >> ${outdir}/${target_stem}.csv
else
    echo “functional connectivity network statistics not available”

fi

echo "Functional module complete!"
echo ""
exit 0
