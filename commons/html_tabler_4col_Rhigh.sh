ms=$1
raw=$2
z=$3
pct=$4

echo "<tr> <td.align="center"> </td> </tr> <td> <td.align="center"_bgcolor=#0000FF.colspan="2"> <td.align="center"_bgcolor=#FF0000.colspan="2"> <td.align="center".colspan="2">" | awk '{ if ("'${z}'" >= 2.0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $2, "'${ms}'", $3, $2, "'${raw}'", $3, $7, "'${z}'", $3, $7, "'${pct}'", $3, $4; else if (("'${z}'"+2.0)<=0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $2, "'${ms}'", $3, $2, "'${raw}'", $3, $6, "'${z}'", $3, $6, "'${pct}'", $3, $4; else printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $2, "'${ms}'", $3, $2, "'${raw}'", $3, $8, "'${z}'",$3, $8, "'${pct}'", $3, $4}' | sed 's/.align/ align/g' | sed 's/_bg/ bg/g' | sed 's/.colspan/ colspan/g'
