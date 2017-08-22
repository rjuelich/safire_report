roi=$1
r1v=$2
r1p=$3
r2v=$4
r2p=$5


if [ ${roi} == "mot_rel_xyz_1mm" ] || [ ${roi} == "mot_rel_xyz_5mm" ] || [ ${roi} == "mot_rel_xyz_max" ] || [ ${roi} == "mot_rel_xyz_mean" ] || [ ${roi} == "mot_rel_xyz_sd" ]
then
	echo "<tr> <td.align="center"> </td> </tr> <td> <td.align="center"_bgcolor=#FF0000> <td.align="center">" | awk '{\
if (r1p>=95 && r2p>=95) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $6, r2v, $3, $6, r2p, $3, $4;\
else if (r1p>=95 && r2p<95 && r2p>5) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $2, r2v, $3, $2, r2p, $3, $4;\
else if (r1p<95 && r1p>5 && r2p>=95) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, r1p, $3, $6, r2v, $3, $6, r2p, $3, $4;\
else if (((r1p) <= 5) && ((r2p) <= 5) && r1p>=0  && r2p>=0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, r1p, $3, $7, r2v, $3, $7, r2p, $3, $4;\
else if (((r1p) <= 5) && r1p>=0 && ((r2p) >= 95)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, r1p, $3, $6, r2v, $3, $6, r2p, $3, $4;\
else if (((r1p) >= 95) && ((r2p) <= 5 && r2p>=0)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $7, r2v, $3, $7, r2p, $3, $4;\
else if (r1p>=95 && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $2, "", $3, $2, "", $3, $4;\
else if (r1p<95 && r1p>5 && r2p<=(-1)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, r1p, $3, $2, "", $3, $2, "", $3, $4;\
else if (r1p<=5 && r1p>=0 && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, r1p, $3, $2, "", $3, $2, "", $3, $4;\
else if (r1p=="-1" && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, "", $3, $2, "", $3, $2, "", $3, $2, "", $3, $4;\
else printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, r1p, $3, $2, r2v, $3, $2, r2p, $3, $4}' r1p=$r1p r2p=$r2p r1v=$r1v r2v=$r2v roi=$roi | sed 's/.align/ align/g' | sed 's/_bg/ bg/g'

elif [ ${roi} == "QCsSNR" ]
then
	echo "<tr> <td.align="center"> </td> </tr> <td> <td.align="center"_bgcolor=#00FFFF> <td.align="center"_bgcolor=#FF0000>" | awk '{\
if (r1p>=95 && r2p>=95) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $6, r2v, $3, $6, r2p, $3, $4;\
else if (r1p>=95 && r2p<95 && r2p>5) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $2, r2v, $3, $2, r2p, $3, $4;\
else if (r1p<95 && r1p>5 && r2p>=95) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, r1p, $3, $6, r2v, $3, $6, r2p, $3, $4;\
else if (((r1p) <= 5) && ((r2p) <= 5) && r1p>=0  && r2p>=0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, r1p, $3, $7, r2v, $3, $7, r2p, $3, $4;\
else if (((r1p) <= 5) && r1p>=0 && ((r2p) >= 95)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, r1p, $3, $6, r2v, $3, $6, r2p, $3, $4;\
else if (((r1p) >= 95) && ((r2p) <= 5 && r2p>=0)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $7, r2v, $3, $7, r2p, $3, $4; else if (r1p>=95 && r2p>=(-1)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $2, "", $3, $2, "", $3, $4;\
else if (r1p<95 && r1p>5 && r2p<=(-1)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, r1p, $3, $2, "", $3, $2, "", $3, $4;\
else if (r1p<=5 && r1p>=0 && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, r1p, $3, $2, "", $3, $2, "", $3, $4;\
else if (r1p=="-1" && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, "", $3, $2, "", $3, $2, "", $3, $2, "", $3, $4;\
else printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, r1p, $3, $2, r2v, $3, $2, r2p, $3, $4}' r1p=$r1p r2p=$r2p r1v=$r1v r2v=$r2v roi=$roi | sed 's/.align/ align/g' | sed 's/_bg/ bg/g'

else
	echo "<tr> <td.align="center"> </td> </tr> <td> <td.align="center"_bgcolor=#FFFFFF> <td.align="center"_bgcolor=#FFFFFF>" | awk '{ if (r1p>=95 && r2p>=95) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, "", $3, $6, r2v, $3, $6, "", $3, $4; else if (r1p>=95 && r2p<95 && r2p>5) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $2, r2v, $3, $2, "", $3, $4; else if (r1p<95 && r1p>5 && r2p>=95) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, r1p, $3, $6, r2v, $3, $6, "", $3, $4; else if (((r1p) <= 5) && ((r2p) <= 5) && r1p>=0  && r2p>=0) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, "", $3, $7, r2v, $3, $7, "", $3, $4; else if (((r1p) <= 5) && r1p>=0 && ((r2p) >= 95)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, r1p, $3, $6, r2v, $3, $6, "", $3, $4; else if (((r1p) >= 95) && ((r2p) <= 5 && r2p>=0)) printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $7, r2v, $3, $7, r2p, $3, $4; else if (r1p>=95 && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $6, r1v, $3, $6, r1p, $3, $2, "", $3, $2, "", $3, $4; else if (r1p<95 && r1p>5 && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, r1p, $3, $2, "", $3, $2, "", $3, $4; else if (r1p<=5 && r1p>=0 && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $7, r1v, $3, $7, r1p, $3, $2, "", $3, $2, "", $3, $4; else if (r1p=="-1" && r2p=="-1") printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, "", $3, $2, "", $3, $2, "", $3, $2, "", $3, $4; else printf "\t%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t\t%s%s%s\n\t%s\n", $1, $5, roi, $3, $2, r1v, $3, $2, "", $3, $2, r2v, $3, $2, "", $3, $4}' r1p=$r1p r2p=$r2p r1v=$r1v r2v=$r2v roi=$roi | sed 's/.align/ align/g' | sed 's/_bg/ bg/g'
fi
