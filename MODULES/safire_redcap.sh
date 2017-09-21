#!/bin/sh
#
#  safire_redcap.sh      : Summarize redcap data for single study participant 
#


if [ $# -lt 2 ]
then
    echo "$0 jbaker v0.1 2017-08-08"
    echo "   usage:  safire_redcap.sh  <subID> <PathToRedcapConfigFile"
    echo ""    
    echo "    N.B. :  requires redcap config file containing key study fields and variables" 
    echo ""
    exit
fi   
subID=$1
pathToRedcapConfigFile=$2

#############################################################
#------------- DO NOT MODIFY BELOW THIS LINE ----------------
#############################################################

# The redcap config file specifies key fields from your project for your request 
redcap_config=$pathToRedcapConfigFile

token=`cat $redcap_config | grep token | awk '{print $2}'`
subIDfield=`cat $redcap_config | grep subIDfield | awk '{print $2}'`
visitIDfield=`cat $redcap_config | grep visitIDfield | awk '{print $2}'`
studydir=`cat $redcap_config | grep studydir | awk '{print $2}'`
outstem=`cat $redcap_config | grep outstem | awk '{print $2}'`
sessionDatefield=`cat $redcap_config | grep sessionDatefield | awk '{print $2}'`

###########################################################################
#
#  First pull Unique Participant IDs into the studyinfo file
#

studyinfo=${studydir}/${outstem}.csv
rm -f $studyinfo

DATA="token=${token}&content=record&format=csv&type=flat&records[0]=${subID}&fields[0]=${subIDfield}&fields[1]=${visitIDfield}&rawOrLabel=raw&rawOrLabelHeaders=raw&exportCheckboxLabel=false&exportSurveyFields=false&exportDataAccessGroups=false&returnFormat=json"

#  This little bit of code should be it's own function call to redcap_curl
CURL=`which curl`
$CURL -H "Content-Type: application/x-www-form-urlencoded" \
      -H "Accept: application/json" \
      -X POST \
      -d $DATA \
      https://redcap.partners.org/redcap/api/  > $studyinfo 2>/dev/null

#  Next cycle through all subIDs and set up folder structure if needed 
echo "Checking ${studydir} folder structure..."

for subID in `cat $studyinfo | grep -v $subIDfield | awk -F ',' '{print $1}' | sort -n | uniq`
do
	studydir_subID=${studydir}/${subID}
	for does_directory_exist in ${studydir_subID} ${studydir_subID}/redcap  ${studydir_subID}/redcap/raw ${studydir_subID}/redcap/processed
	do
		if [ ! -e ${does_directory_exist} ]
		then
			mkdir ${does_directory_exist}
		fi
	done
done

isSubjectIDInREDCap=`cat $studyinfo | grep $subID | awk -F ',' '{print $1}' | uniq`

if [ `echo $isSubjectIDInREDCap | wc -c` -lt 1 ]
then
	echo "Participant $subID does not exist in this REDCap Project."
	exit
fi

rawout=${studydir}/${subID}/redcap/raw
procout=${studydir}/${subID}/redcap/processed
out=${rawout}/${subID}_redcap_${outstem}.csv

if [ -e $out ]
then
	rm -f $out
fi
touch $out

echo ""
echo "*************************************************************************"
echo "REDCAP Data for participant ${subID} will be stored in ${rawout} in file $out"
printf "Variable: "

redcap_vars=`cat $redcap_config | grep ^fields | awk '{print $2}'`

for var in $redcap_vars
do
	printf "."
	outvar=${rawout}/${subID}_redcap_${outstem}_${var}.csv
	if [ -e $outvar ]
	then
	    rm -f $outvar
	fi
	touch $outvar
	DATA="token=${token}&content=record&format=csv&type=flat&records[0]=${subID}&fields[0]=${subIDfield}&fields[1]=${visitIDfield}&fields[2]=${sessionDatefield}&fields[3]=${var}&rawOrLabel=raw&rawOrLabelHeaders=raw&exportCheckboxLabel=false&exportSurveyFields=false&exportDataAccessGroups=false&returnFormat=json"
	CURL=`which curl`
	$CURL -H "Content-Type: application/x-www-form-urlencoded" \
	      -H "Accept: application/json" \
	      -X POST \
	      -d $DATA \
	      https://redcap.partners.org/redcap/api/   > $outvar 2>/dev/null
	done

	var1=`echo $redcap_vars | awk '{print $1}'`
	events=`cat ${rawout}/*${var1}*.csv | grep -v redcap_event_name | awk -F ',' '{print $2}' | sort -u`

	for var in $subIDfield redcap_event_name $visitIDfield $sessionDatefield $redcap_vars
        do
              printf "$var," >> $out
        done
	echo "" >> $out

	for event in $events
	do
		visitID_column=`head -1 ${rawout}/${subID}_redcap_${outstem}_${var}.csv | pcut -cs ',' -t | grep -n "" | grep $visitIDfield | awk -F : '{print $1}'`
	
		visitID_values=`cat ${rawout}/${subID}_redcap_${outstem}_${var}.csv | grep $event | awk -v var_col=${visitID_column} -F ',' '{printf("%s,", $var_col )}'`

		for visitID_value in `echo $visitID_values | pcut -cs ',' -t`
		do
			printf "${subID},${event}," >> $out
			echo -n "${visitID_value}," >> $out

			sessionDatefield_column=`head -1 ${rawout}/${subID}_redcap_${outstem}_${var}.csv | pcut -cs ',' -t | grep -n "" | grep $sessionDatefield | awk -F : '{print $1}'`
			sessionDatefield_value=`cat ${rawout}/${subID}_redcap_${outstem}_${var}.csv | grep $event | grep $visitID_value | awk -v var_col=${sessionDatefield_column} -F ',' '{printf("%s,", $var_col )}'`
			echo -n "${sessionDatefield_value}" >> $out

			for var in $redcap_vars
			do
				var_column=`head -1 ${rawout}/${subID}_redcap_${outstem}_${var}.csv | pcut -cs ',' -t | grep -n "" | grep $var | awk -F : '{print $1}'`
#				echo var column $var_column
				var_value=`cat ${rawout}/${subID}_redcap_${outstem}_${var}.csv | grep $event |  grep $visitID_value | awk -v var_col=${var_column} -F ',' '{printf("%s,", $var_col )}'` 
#				echo var value $var_value
				echo -n $var_value >> $out
#				echo  var $var var column $var_column var value $var_value 
			done
			echo "" >> $out
		done
	done

	for var in $redcap_vars
	do
		outvar=${rawout}/${subID}_redcap_${outstem}_${var}.csv
		if [ -e $outvar ]
		then
		    rm -f $outvar
		fi
	done
echo ""
echo "Created $out :"
 cat $out
echo ""

function redcap_raw_to_processed
{
	echo processing redcap files and moving from source to target
}

