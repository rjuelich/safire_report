#!/bin/sh
#
#  Is designed to run only what has not already completed on each case
#  

SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
commons="${SCRIPT_DIR}/commons"
#**************************************************************************
# -----------  DO NOT CHANGE BELOW THIS LINE ----
#**************************************************************************

if [ $# -lt 1 ]
then
	echo "Id: safire,v 1.8 2016/03/31 09:17:10 jbaker Exp $"
        echo "Usage: safire <SESSION_ID> [<XNAT> <PROJECT>] "
        echo "       :  where SESSION_ID is the only required argument"
	echo "	     :  if XNAT is not provided, SessID_xnat.csv must exist "
        echo "  e.g. :  safire.sh 160315_ML0001  <-- requires 160315_ML0001_xnat.csv file in session dir"
        echo "  e.g. :  safire.sh 160216_HTP01821 cbscentral BLS "
	exit
fi

study_dir=`pwd`
case=$1
xnat=$2
project=$3

study_home=`grep ${project} /eris/sbdp/GSP_Subject_Data/SCRIPTS/.mclcentral_psf_cron_config | awk -F , '{print $2}'`

sub=${case}  # Work to make variable consistent, i.e., use $case throughout session is case is sub

# Where files should be written
case_dir=${study_dir}/$case
fs_dir=${study_dir}/${case}_FS
outdir=${case_dir}/qc/INDIV_MAPS

if [ ! -e ${outdir} ]
then
	if [ ! -e ${case_dir}/qc ]
	then
		mkdir ${case_dir}/qc
	fi

	mkdir ${case_dir}/qc/INDIV_MAPS
fi

${MODULE_DIR}/safire_xnat.sh ${case} ${xnat} ${project}
${MODULE_DIR}/safire_struc.sh ${case_dir}/${case}_xnat.csv
${MODULE_DIR}/safire_func.sh ${case_dir}/${case}_xnat.csv
${MODULE_DIR}/safire_html.sh ${case_dir}/${case}_xnat.csv

exit 0
