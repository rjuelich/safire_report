#!/bin/bash

# USAGE
# for sub in `cat {sublist}`; do for val in R A B SNR1 SNR2; do qct_htmlgen.sh `grep ${val} ${sub}/qc/INDIV_MAPS/${sub}_qc_table.txt | awk '{print $1, $2, $3, $4, "'${sub}'"}'`

ms=$1
val=$2
val=`echo ${val} | awk '{printf "%.2f\n", $1}'`
z=$3
pct=$4
sub=$5
sdir="${sub}/qc/INDIV_MAPS"


echo "<tr> <td.align="center"> </td> </tr> <td> <td.align="center"_bgcolor=#FF0000> <td.align="center"_bgcolor=#0000FF> <td.align=left> <td.colspan="2".align=center> <td.colspan="2".align=center_bgcolor=#FF0000> <td.colspan="2".align=center_bgcolor=#0000FF>" | awk '{\
 if ("'${z}'">=2.0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $8, "'${ms}'", $3, $7, "'${val}'", $3, $7, "'${z}'", $3, $11, "'${pct}'", $3, $4;\
else if (("'${z}'"+2.0) <= 0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $8, "'${ms}'", $3, $6, "'${val}'", $3, $6, "'${z}'", $3, $10, "'${pct}'", $3, $4;\
else printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $8, "'${ms}'", $3, $2, "'${val}'", $3, $2, "'${z}'", $3, $9, "'${pct}'", $3, $4}' | sed 's/.align/ align/g' | sed 's/_bg/ bg/g' | sed 's/center_/center /g' | sed 's/.colspan/ colspan/g' >> ${sdir}/${sub}_qchtml.tmp

#echo "qct_htmlgen ${ms} complete"
