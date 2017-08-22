#!/bin/bash

########################################
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
commons="${SCRIPT_DIR}/commons"
######################################
sub=$1

if [ -e ${sub}/qc/INDIV_MAPS/${sub}_17nethtml.txt ]
then
	rm ${sub}/qc/INDIV_MAPS/${sub}_17nethtml.txt
fi

for roi in `awk '{print $1}' ${sub}/qc/INDIV_MAPS/${sub}_17net_table.txt`
do
	${commons}/func_htmlgen.sh `grep ${roi} ${sub}/qc/INDIV_MAPS/${sub}_17net_table.txt`
done > ${sub}/qc/INDIV_MAPS/${sub}_17nethtml.txt

