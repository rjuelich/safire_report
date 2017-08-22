#USEAGE
# 17nethtml_wrap.sh {SubID}

sub=$1

if [ -e ${sub}/qc/INDIV_MAPS/${sub}_17nethtml.txt ]
then
	rm ${sub}/qc/INDIV_MAPS/${sub}_17nethtml.txt
fi

for roi in `awk '{print $1}' ${sub}/qc/INDIV_MAPS/${sub}_17net_table.txt`
do
	17net_html-gen.sh `grep ${roi} ${sub}/qc/INDIV_MAPS/${sub}_17net_table.txt`
done > ${sub}/qc/INDIV_MAPS/${sub}_17nethtml.txt
#| cat /eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_17net_TABLES/hdr.txt - >> ${sub}/qc/INDIV_MAPS/${sub}_17nethtml.txt

