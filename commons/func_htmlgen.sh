roi=$1
z=$2
pct=$3


echo "<tr> <td.align="center"> </td> </tr> <td> <td.align="center"_bgcolor=#FF0000> <td.align="center"_bgcolor=#0000FF>" | awk '{\
 if ("'${z}'">=2.0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, "'${roi}'", $3, $7, "'${z}'", $3, $7, "'${pct}'", $3, $4;\
else if (("'${z}'"+2.0) <= 0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, "'${roi}'", $3, $6, "'${z}'", $3, $6, "'${pct}'", $3, $4;\
else printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, "'${roi}'", $3, $2, "'${z}'", $3, $2, "'${pct}'", $3, $4;\
}' | sed 's/.align/ align/g' | sed 's/_bg/ bg/g'
