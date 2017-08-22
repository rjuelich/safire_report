#!/bin/sh
#
#  
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"

#**************************************************************************
# -----------  DO NOT CHANGE BELOW THIS LINE ----
#**************************************************************************

if [ $# -lt 1 ]
then
	echo "Id: safire_header,v 1.8 2016/03/31 09:17:10 jbaker Exp $"
        echo "Usage: safire_header <SESSION_ID> [<XNAT> <PROJECT>] "
        echo "       :  where SESSION_ID is the only required argument"
	echo "	     :  if XNAT is not provided, SessID_xnat.csv must exist "
        echo "  e.g. :  safire_header 160315_ML0001  <-- requires 160315_ML0001_xnat.csv file in session dir"
	exit
fi

# Setting up variables with source and destination dir structure

study_dir=`pwd`
session=$1
session_dir=${study_dir}/$session
outdir=${session_dir}/qc/INDIV_MAPS

datestr=`date +%y%m%d_%H%M`
summlog="${study_dir}/${session}/${session}_safireheader_${datestr}.log"

if [ -e ${session_dir}/${session}_clin.csv ]
then
	if [ `grep -c use ${session_dir}/${session}_clin.csv` -ge 1 ]
	then
		scales=`awk '{ if ($3=="use") print $1}' ${session_dir}/${session}_clin.csv | paste -s -d , -`
	fi
	
	if [ `grep -i -c dx ${session_dir}/${session}_clin.csv` = 1 ]
	then
		dx=`grep -i dx ${session_dir}/${session}_clin.csv | awk '{print $2}'`
	fi
fi

# DEfining variables to identify files we want to parse 
if [ -e ${session_dir}/bold ]
then
	boldrunstr=`ls -1 ${session_dir}/bold/ | grep ^0 | head -1 `
	boldrun=`echo $boldrunstr | sed s/^0//g | sed s/^0//g`
	boldnii=${session_dir}/bold/${boldrunstr}/${session}_bld${boldrunstr}_rest.nii
	numbold=`ls -1 ${session_dir}/bold/ | grep ^0 | wc -w`

	ntrs=`fslhd ${boldnii} | grep ^dim4 | awk '{print $2}'`
else
	boldrun=$4
	echo ${boldrun}
fi

if [ $2 ]
then
	xnat=$2
fi

if [ $3 ]
then
	project=$3
fi

# Aim to remove 
if [ `echo $* | grep -c force | awk '{print $1}'` -gt 0 ]
then
	rm -rf ${outdir}
fi


if [ ! -e $outdir ]
then
	mkdir $outdir
fi



#  Use existing xnat.csv if it exists, else use existing DICOMs, else pull them from XNAT
echo "Gathering DICOM HEADER info...should just be a minute or two"
if [ ! -e ${session_dir}/${session}_xnat.csv ]
then
	if [ ! -e ${session}/RAW ] && [ ! -e ${session}/arcget ]
	then
		if [ ! $xnat ]
		then
			echo "Neither RAW nor arcget exist, and no xnat specified"
			exit 1
		fi

		#  First pull a single BOLD run from XNAT
		echo "Pulling BOLD DICOMs from $xnat ..."
		ArcGet.py -a ${xnat} -s ${session} -r ${boldrun}
	fi

	# By now, you have a folder with at least some DICOMs
	# Identify first BOLD DICOM
	for dir in `ls -d ${session_dir}/* `
	do
		for file in `ls ${dir} | grep -v gif | head -1`
		do
			type=`file -n ${dir}/$file | awk '{for (n=1;n<=NF;n++) if ($n=="DICOM") print $n}'`
			if [ "$type" = "DICOM" ]
			then
				rawdir=$dir
				echo $rawdir	
				for dcm in `ls ${rawdir}/* | grep -v gif`
				do
					if [ `dcm2xml $dcm | grep SeriesNumber | awk -F '>|<' '{print $3}'` == "$boldrun" ]
					then
						bolddcm=$dcm
						break
					fi
				done
			fi
		done
	done
	
	# Now we have a defined BOLD DICOM to pull header info
	# So we create the XNAT.csv file from all the available info
	echo "SubID ${session}" >> ${session}/${session}_xnat.csv
	echo "SessionID ${session}" >> ${session}/${session}_xnat.csv
	echo "boldrun ${boldrun}" >> ${session}/${session}_xnat.csv
	dcm2xml $bolddcm | grep PatientsAge | awk -F '>|<' '{print $3}' | sed s/^0//g | sed s/Y//g | awk '{printf("age %d\n",$1)}' >> ${session}/${session}_xnat.csv

	fslhd $boldnii | egrep '^dim1|^dim2|^dim3|^pixdim1|^pixdim2|^pixdim3|^pixdim4|^dim4' | awk '{print $2}' | paste -s | awk '{printf("[%sx%sx%s]@[%.2fx%.2fx%.2fmm]@[%.3fsec]X[%svols]x[%druns]\n", $1, $2, $3, $5, $6, $7, $8, $4, NUMBOLD)}' NUMBOLD=$numbold | awk '{printf("seqinfo %s\n",$1)}' >> ${session}/${session}_xnat.csv
	
	dcm2xml $bolddcm | grep -w Manufacturer | awk -F '>|<' '{print $3}' | awk '{printf("manufact %s\n",$1)}' >> ${session}/${session}_xnat.csv

	dcm2xml $bolddcm | grep ManufacturersModelName | awk -F '>|<' '{print $3}' | awk '{printf("scanner %s\n",$1)}' >> ${session}/${session}_xnat.csv
	
	strings $bolddcm | grep RxCoil | grep CoilID | head -1 | awk '{print $NF}' | sed -e '/\"/s///g' | awk '{printf("coil %s\n",$1)}' >> ${session}/${session}_xnat.csv
	
	echo "visit ${visit}" >> ${session}/${session}_xnat.csv
	echo "project ${project}" >> ${session}/${session}_xnat.csv
fi

age=`grep -i age ${session}/${session}_xnat.csv | awk '{print $2}'`
scanner=`grep -i scanner ${session}/${session}_xnat.csv | awk '{print $2}'`
coil=`grep -i coil ${session}/${session}_xnat.csv | awk '{print $2}'`
seqinfo=`grep -i seq ${session}/${session}_xnat.csv | awk '{print $2}'`
manufact=`grep -i manufact ${session}/${session}_xnat.csv | awk '{print $2}'`

# These are all CORE features of the DICOM acquisition needed for processing
# Next we wil try to extract DEMOGRAPHICS from available data
#  At this point, we have defined AGE, seqinfo, scanner, coil in all sessions

if [ `grep -i -c sex ${session_dir}/${session}_xnat.csv` -gt 0 ]
then
	sex=`grep -i sex ${session_dir}/${session}_xnat.csv | awk '{print $2}' | head -1`
fi

if [ `grep -i -c race ${session_dir}/${session}_xnat.csv` -gt 0 ]
then
	race=`grep -i race ${session_dir}/${session}_xnat.csv | awk '{print $2}' | head -1`
fi

if [ `grep -i -c studyID ${session_dir}/${session}_xnat.csv` -gt 0 ]
then
	studyID=`grep -i studyID ${session_dir}/${session}_xnat.csv | awk '{print $2}' | head -1`
fi

if [ ! ${xnat} ] && [ `grep -i -c xnat ${session_dir}/${session}_xnat.csv` -gt 0 ]
then
	xnat=`grep -i xnat ${session_dir}/${session}_xnat.csv | awk '{print $2}' | head -1`
fi

if [ `grep -i -c xnat ${session_dir}/${session}_xnat.csv` -lt 1 ]
then
	echo "xnat ${xnat}" >> ${session_dir}/${session}_xnat.csv
fi

if [ ! ${project} ]
then
	project=`grep -i project ${session_dir}/${session}_xnat.csv | awk '{print $2}' | head -1`
fi




if [ ! $sex ]
then
	if [ $xnat ]
	then
		echo "Pulling Demographic Information from $xnat ..."
		ArcGet.py -a ${xnat} -s $session -readme > ${outdir}/${session}.readme

		sex=`cat ${outdir}/${session}.readme | grep GENDER | awk '{print $2}' | sed 's/female/FEMALE/g' | sed 's/male/MALE/g' | head -1`
		studyID=`cat ${outdir}/${session}.readme | grep SUBJECT | awk '{print $2}'  | head -1`
		race=`cat ${outdir}/${session}.readme | grep -w RACE | awk '{print $2}'  | head -1`

        if [ `grep -i -c sex ${session_dir}/${session}_xnat.csv` -lt 1 ]
        then
		    echo "sex ${sex}" >> ${session_dir}/${session}_xnat.csv
        fi
        if [ `grep -i -c studyID ${session_dir}/${session}_xnat.csv` -lt 1 ]
        then
		    echo "studyID ${studyID}" >> ${session_dir}/${session}_xnat.csv
        fi
        if [ `grep -i -c race ${session_dir}/${session}_xnat.csv` -lt 1 ]
        then
		    echo "race ${race}" >> ${session_dir}/${session}_xnat.csv
        fi
	fi
fi

if [ $dx ]
then
        if [ `grep -i -c dx ${session_dir}/${session}_xnat.csv` -lt 1 ]
        then
            echo DX $dx >> ${session_dir}/${session}_xnat.csv
        fi
fi

# At this point, All demographic variables are set!


echo ""
echo "--PARTICIPANT INFO-------------------------------------------"
echo "	Project:    	$project"
echo "	Subject ID:    	$studyID"
echo "	SessionID:  	$session"
echo "	Data folder:	$study_dir"
echo "	Summary Log:	$summlog"
echo "	XNAT:       	$xnat"
echo "--DEMOGRAPHICS-------------------------------------------"
echo "	Age:        	$age"
echo "	Sex:	        $sex"
echo "	Race:	    	$race"
echo "--MRI INFO-----------------------------------------------"
echo "	Manufact:    	$manufact"
echo "	Scanner:    	$scanner"
echo "	Coil:           $coil"
echo "	BOLD run:   	$boldrun"
echo "	Seq Info:       $seqinfo"
echo "---------------------------------------------------------"
echo ""
printf "Generating HTML header info..."
#${MODULE_DIR}/safire_html_hdr.sh ${session_dir}/${session}_xnat.csv ${scales} 2&>> ${summlog}
${MODULE_DIR}/safire_html_hdr.sh ${session_dir}/${session}_xnat.csv ${scales} 

#sed -i s/age/${age}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/study/${study}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/SubID/${session}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/sex/${sex}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/race/${race}/g ${outdir}/${session}_htmlhdr.txt
#sed -i 's/dx/'${dx}'/g' ${outdir}/${session}_htmlhdr.txt
#sed -i "s/>tr</>${tr}</g" ${outdir}/${session}_htmlhdr.txt
#sed -i s/seqinfo/${seqinfo}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/scanner/${scanner}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/coil/${coil}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/StudyID/${studyID}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/visit/${visit}/g ${outdir}/${session}_htmlhdr.txt
#
#
#sed -i s/meas1/${meas1}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/meas2/${meas2}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/meas3/${meas3}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/meas4/${meas4}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/meas5/${meas5}/g ${outdir}/${session}_htmlhdr.txt
#
#sed -i s/val1/${val1}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/val2/${val2}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/val3/${val3}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/val4/${val4}/g ${outdir}/${session}_htmlhdr.txt
#sed -i s/val5/${val5}/g ${outdir}/${session}_htmlhdr.txt
#
#sed -i s/xnat/${xnat}/g ${outdir}/${session}_htmlhdr.txt
#
echo "Complete."
exit 0
