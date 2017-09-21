#!/bin/bash

SCRIPT_DIR="/eris/sbdp/GSP_Subject_Data/SCRIPTS/gits/safire_package"
MODULE_DIR="${SCRIPT_DIR}/MODULES"
HTML_DIR="${SCRIPT_DIR}/HTML_TEMPLATES"


# Creates latest HTML cover page based on the session statistics data available.
# If data are not present in directory, then an empty template is created
# with placeholders showing the data that are expected after processing completes..

# Assumptions:
#  	Start with session concise statistics files:
#
#	Cases:
#		1. Files do not exist
#			Result: create an empty template to deliver
#			
#		2. Files exist and are not in expected structure 
#			Result: create an empty template to deliver
#
#		3. Files exist and are in expected structure
#			Result: deliver html in standard format
# 				<study_dir>/<session_id>_FS/<session_id>_mri_struc_concise.csv 
# 				<study_dir>/<session_id>/<session_id>_mri_func_concise.csv 
# 				<study_dir>/<session_id>/<session_id>_redcap_concise.csv 
#
#	Output HTML is written to study data directory
#		Example: /eris/ressler/Data 
#
#

# Example
#
# call structure - 
# create study specific code to iterate over each session directory:
# see /eris/ressler/Data/dd_cover.sh
#
# for loop
#  cd to /eris/ressler/Data/2GFZM/mri
#  set xnat_csv=/eris/ressler/Data/2GFZM/mri/160513_NTD065/160513_NTD065_xnat.csv
# call safire_cover.sh ${xnat_csv}

# full path to xnat.csv file
csv=$1

session=`grep -i SubID ${csv} | awk '{print $2}'`
studyID=`grep -i studyID ${csv} | awk '{print $2}'`
study=`grep -i project ${csv} | awk '{print $2}'`

datestr=`date +%y%m%d_%H%M`
processlog="${study_dir}/${session}/${session}_struct_${datestr}.log"

# full path to directory containing session
study_dir=`pwd`

subject_dir=`echo ${study_dir} | sed 's/mri//g'` 
subject_mri_dir=${subject_dir}/mri
subject_redcap_dir=${subject_dir}/redcap
output_dir=`echo ${subject_dir} | sed 's/${studyID}//g'`

echo output dir ${output_dir}

# full path to each concise statistics csv file
input_mri_struc=${subject_mri_dir}/${session}_FS/${session}_mri_struc_concise.csv
input_mri_func=${subject_mri_dir}/${session}/${session}_mri_func_concise.csv
input_redcap=${subject_redcap_dir}/${session}_redcap_concise.csv

output_html_subject_cover=${subject_dir}/${studyID}_${session}_output.html
echo $output_html_subject_cover 

# full path to output file rows
output_html_file_rows=${output_dir}/${study}_cover_rows.html

# full path to output html file
output_html_file=${output_dir}/${study}_cover.html

#ROW OF SUBJECT specific SESSION to be included in FINAL OUTPUT FILE OF ALL SESSIONS

subject_session_output_section=`echo '<tr width="100%"><td bgcolor=#999999 width="1%"></td><td align=center bgcolor=#999999 width="5.5%"></td><td align=center bgcolor=#999999 width="2%"></td><td bgcolor=#999999 width="13%"></td>'`

subject_session_output_section=${subject_session_output_section}`cat ${input_redcap} | head -1 | awk -F , '{OFS=""; print "<td align=center width=5.5%>", $1, "</td>", "<td align=center width=5.5%>", $2, "</td>", "<td align=center width=3%>", $3, "</td>", "<td align=center width=3%>", $4, "</td>"}'`

subject_session_output_section=${subject_session_output_section}`cat ${input_mri_struc} | head -1 | awk -F , '{OFS=""; print "<td align=center width=5.5%>", $1, "</td>", "<td align=center width=5.5%>", $2, "</td>", "<td align=center width=3%>", $3, "</td>", "<td align=center width=3%>", $4, "</td>"}'`

subject_session_output_section=${subject_session_output_section}`cat ${input_mri_func} | head -1 | awk -F , '{OFS=""; print "<td align=center width=5.5%>", $1, "</td>", "<td align=center width=5.5%>", $2, "</td>", "<td align=center width=3%>", $3, "</td>", "<td align=center width=3%>", $4, "</td>"}'`

subject_session_output_section=${subject_session_output_section}`echo "</tr>"`

subject_session_output_section=${subject_session_output_section}`echo ""`

subject_session_output_section=${subject_session_output_section}`echo '<tr width="100%" style="page-break-inside: avoid;"><td width=1% align=center><a href='PDFs/${session}.pdf' target="_blank">'__ROW_NUMBER__'</a></td><td width=5.5% align=center><a href="https://redcap.partners.org/redcap/redcap_v7.0.14/DataEntry/record_home.php?pid=5739&arm=1&id='${studyID}'">'${studyID}'</a></td><td align=center>'__VISIT__'</td><td width=13% align=center><a href="http://xnat.mclean.harvard.edu/data/archive/projects/'${study}'/subjects/'${studyID}'/experiments/'${session}'" target="_blank">'${session}'</a></td>'`

### Replace __ROW_NUMBER__ with actual row number
### Replace __VISIT__ with visit number - increment over date string part of ${session}

###ROW OF SUBJECT specific SESSION to be included in FINAL OUTPUT FILE OF ALL SESSIONS
subject_session_output_section=${subject_session_output_section}`cat ${input_redcap} | tail -1 | awk -F , '{OFS=""; print "<td align=center width=5.5%>", $1, "</td>", "<td align=center width=5.5%>", $2, "</td>", "<td align=center width=3%>", $3, "</td>", "<td align=center width=3%>", $4, "</td>"}'`

subject_session_output_section=${subject_session_output_section}`cat ${input_mri_struc} | tail -1 | awk -F , '{OFS=""; print "<td align=center width=5.5%>", $1, "</td>", "<td align=center width=5.5%>", $2, "</td>", "<td align=center width=3%>", $3, "</td>", "<td align=center width=3%>", $4, "</td>"}'`

subject_session_output_section=${subject_session_output_section}`cat ${input_mri_func} | tail -1 | awk -F , '{OFS=""; print "<td align=center width=5.5%>", $1, "</td>", "<td align=center width=5.5%>", $2, "</td>", "<td align=center width=3%>", $3, "</td>", "<td align=center width=3%>", $4, "</td>"}'`

subject_session_output_section=${subject_session_output_section}`echo "</tr>"`

### Write the latest - do not check old output
echo ${subject_session_output_section} > ${output_html_subject_cover} 

###FINAL OUTPUT FILE OF ALL SESSIONS
### combine output of currently available output html for subjects

output_content=`cat ${HTML_DIR}/safire_cover_template.html | sed "s/_gentime_/${datestr}/g" | sed "s/_project_/${study}/g"`

### Add current subject session header and content to cover file
output_content=${output_content}`echo ${subject_session_output_section}`

### Include previously accumulated content rows to cover file
output_content=${output_content}`cat ${output_html_file_rows}`

output_content=${output_content}`echo "</table>"`
output_content=${output_content}`echo "</body>"`
output_content=${output_content}`echo "</html>"`

echo ${output_content} > ${output_html_file}

### Update content rows to include latest subject session
echo ${subject_session_output_section} | tail -1 >> ${output_html_file_rows}

