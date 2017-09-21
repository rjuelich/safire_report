#!/bin/sh
#
#  

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

study_dir=`pwd`
session=$1
session_dir=${study_dir}/$session
outdir=${session_dir}/qc/INDIV_MAPS
SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
htmldir="/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_HTML"

if [ $2 ]
then
	xnat=$2
fi

if [ $3 ]
then
	project=$3
fi



if [ ! -e $outdir ]
then
	mkdir $outdir
fi

datestr=`date +%y%m%d_%H%M`
summlog="${study_dir}/${session}/${session}_safireheader_${datestr}.log"

#######################################################################
# --------------------- LEGACY : To be removed -----------------------#
#######################################################################
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

if [ `echo $* | grep -c force | awk '{print $1}'` -gt 0 ]
then
	rm -rf ${outdir}
fi




#  Use existing xnat.csv if it exists, else use existing DICOMs, else pull them from XNAT
if [ ! -e ${session_dir}/${session}_xnat.csv ]
then
    echo "Gathering DICOM HEADER info...should just be a minute or two"
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

    #  Assuming case has undergone basic processing, determine which is BOLD series 
    if [ -e ${session_dir}/bold ]
    then
        boldrunstr=`ls -1 ${session_dir}/bold/ | grep ^0 | head -1 `
        boldrun=`echo $boldrunstr | sed s/^0//g | sed s/^0//g`
        boldnii=${session_dir}/bold/${boldrunstr}/${session}_bld${boldrunstr}_rest.nii
        numbold=`ls -1 ${session_dir}/bold/ | grep ^0 | wc -w`
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
	
    age=`dcm2xml $bolddcm | grep PatientsAge | awk -F '>|<' '{print $3}' | sed s/^0//g | sed s/Y//g`
	seqinfo=`fslhd $boldnii | egrep '^dim1|^dim2|^dim3|^pixdim1|^pixdim2|^pixdim3|^pixdim4|^dim4' | awk '{print $2}'  | paste -s | \
            awk '{printf("[%sx%sx%s]@[%.2fx%.2fx%.2fmm]@[%.3fsec]X[%svols]x[%druns]\n", $1, $2, $3, $5, $6, $7, $8, $4, NUMBOLD)}' NUMBOLD=$numbold`
	manufact=`$dcm2xml $bolddcm | grep -w Manufacturer | awk -F '>|<' '{print $3}'`
	scanner=`dcm2xml $bolddcm | grep ManufacturersModelName | awk -F '>|<' '{print $3}'`
	coil=`strings $bolddcm | grep RxCoil | grep CoilID | head -1 | awk '{print $NF}' | sed -e '/\"/s///g'` 


	# From XNAT 
	echo "SubID ${session}" >> ${session}/${session}_xnat.csv
	echo "SessionID ${session}" >> ${session}/${session}_xnat.csv
	echo "boldrun ${boldrun}" >> ${session}/${session}_xnat.csv
	echo "visit ${visit}" >> ${session}/${session}_xnat.csv
	echo "project ${project}" >> ${session}/${session}_xnat.csv

    # From DICOM header
    echo "age $age" >> ${session}/${session}_xnat.csv
    echo "seqinfo $seqinfo" >> ${session}/${session}_xnat.csv
    echo "manufact $manufact" >> ${session}/${session}_xnat.csv
    echo "scanner $scanner" >> ${session}/${session}_xnat.csv
    echo "coil $coil" >> ${session}/${session}_xnat.csv
else
        echo "Using existing ${session_dir}/${session}_xnat.csv file"
        age=`grep -i age ${session_dir}/${session}_xnat.csv | awk '{print $2}'`
        seqinfo=`grep -i seq ${session_dir}/${session}_xnat.csv | awk '{print $2}'`
        manufact=`grep -i manufact ${session_dir}/${session}_xnat.csv | awk '{print $2}'`
        scanner=`grep -i scanner ${session_dir}/${session}_xnat.csv | awk '{print $2}'`
        coil=`grep -i coil ${session_dir}/${session}_xnat.csv | awk '{print $2}'`
fi


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

if [ `cat ${session_dir}/${session}_xnat.csv | grep DX | wc -l` -lt 1 ]
then
    echo "${session_dir}/${session}_xnat.csv is missing DX!!"
     echo DX $dx >> ${session_dir}/${session}_xnat.csv
fi

echo ""
echo "--PARTICIPANT INFO-------------------------------------------"
echo "	Project:    	$project"
echo "	Subject ID:    	$studyID"
echo "	SessionID:  	$session"
echo "	SessionDIR:  	$session_dir"
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

#####################################################
# ------------- LEGACY: TO BE REMOVED ------------- #
#####################################################

if [ `echo ${scales} | awk -F , '{print NF}'` -ge 5 ]
then
    echo "Found scales: $scales"
	meas1=`echo ${scales} | awk -F , '{print $1}'`
	meas2=`echo ${scales} | awk -F , '{print $2}'`
	meas3=`echo ${scales} | awk -F , '{print $3}'`
	meas4=`echo ${scales} | awk -F , '{print $4}'`
	meas5=`echo ${scales} | awk -F , '{print $5}'`
	val1=`grep ${meas1} ${session}/${session}_clin.csv | awk '{print $2}'`
	val2=`grep ${meas2} ${session}/${session}_clin.csv | awk '{print $2}'`
	val3=`grep ${meas3} ${session}/${session}_clin.csv | awk '{print $2}'`
	val4=`grep ${meas4} ${session}/${session}_clin.csv | awk '{print $2}'`
	val5=`grep ${meas5} ${session}/${session}_clin.csv | awk '{print $2}'`
else
        meas1="_"
        meas2="_"
        val1="_"
        val2="_"
        meas3="_"
        val3="_"
        meas4="_"
        val4="_"
        meas5="_"
        val5="_"
fi
        
#####################################################
#####################################################
#####################################################

#  Finally convert the ${session}_xnat.csv file into HTML by copying from template 

if [ -e ${outdir}/${session}_htmlhdr.txt ]
then
    rm ${outdir}/${session}_htmlhdr.txt
fi
cp ${htmldir}/hdr_template.txt ${outdir}/${session}_htmlhdr.txt

sed -i s/age/${age}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/study/${study}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/SubID/${session}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/sex/${sex}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/race/${race}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/dx/${dx}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/seqinfo/${seqinfo}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/scanner/${scanner}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/coil/${coil}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/StudyID/${studyID}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/visit/${visit}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/meas1/${meas1}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/meas2/${meas2}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/meas3/${meas3}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/meas4/${meas4}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/meas5/${meas5}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/val1/${val1}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/val2/${val2}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/val3/${val3}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/val4/${val4}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/val5/${val5}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/xnat/${xnat}/g ${outdir}/${session}_htmlhdr.txt
sed -i s/\>tr\</\>${tr}\</g ${outdir}/${session}_htmlhdr.txt

if [ ! -e sbdp_logo.png ]
then 
	cp ${SCRIPT_DIR}/ICONS/sbdp_logo.png ./
fi

echo "Complete."
exit 0
