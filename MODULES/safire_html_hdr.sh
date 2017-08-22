#USEAGE
# gen_htmlheader.sh {SubID} {STUDY}
# 
# For now this must be run from main mri folder

csv=$1
scales=$2

study=`grep -i project ${csv} | awk '{print $2}'`
xnat=`grep -i xnat ${csv} | awk '{print $2}'`
age=`grep -i age ${csv} | awk '{print $2}'`
sex=`grep -i sex ${csv} | awk '{print $2}'`
race=`grep -i race ${csv} | awk '{print $2}'`
tr=`grep -i ^TR ${csv} | awk '{print $2}'`
dx=`grep -i DX ${csv} | awk '{print $2}'`
studyID=`egrep -i studyID ${csv} | awk '{print $2}'`
sub=`grep -i SubID ${csv} | awk '{print $2}'`
seqinfo=`grep -i seq ${csv} | awk '{print $2}'`
scanner=`grep -i SCANNER ${csv} | awk '{print $2}'`
visit=`grep -i VISIT ${csv} | awk '{print $2}'`
coil=`grep -i COIL ${csv} | awk '{print $2}'`

hdir="/eris/sbdp/GSP_Subject_Data/SCRIPTS/PSF_HTML"

study_dir=`pwd`
sdir="${study_dir}/${sub}/qc/INDIV_MAPS"




if [ `echo ${scales} | awk -F , '{print NF}'` -ge 5 ]
then
	meas1=`echo ${scales} | awk -F , '{print $1}'`
	meas2=`echo ${scales} | awk -F , '{print $2}'`
	meas3=`echo ${scales} | awk -F , '{print $3}'`
	meas4=`echo ${scales} | awk -F , '{print $4}'`
	meas5=`echo ${scales} | awk -F , '{print $5}'`
	val1=`grep ${meas1} ${sub}/${sub}_clin.csv | awk '{print $2}'`
	val2=`grep ${meas2} ${sub}/${sub}_clin.csv | awk '{print $2}'`
	val3=`grep ${meas3} ${sub}/${sub}_clin.csv | awk '{print $2}'`
	val4=`grep ${meas4} ${sub}/${sub}_clin.csv | awk '{print $2}'`
	val5=`grep ${meas5} ${sub}/${sub}_clin.csv | awk '{print $2}'`
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
        

if [ -e ${sdir}/${sub}_htmlhdr.txt ]
then
    rm ${sdir}/${sub}_htmlhdr.txt
fi
cp ${hdir}/hdr_template.txt ${sdir}/${sub}_htmlhdr.txt

sed -i s/age/${age}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/study/${study}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/SubID/${sub}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/sex/${sex}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/race/${race}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/dx/${dx}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/seqinfo/${seqinfo}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/scanner/${scanner}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/coil/${coil}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/StudyID/${studyID}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/visit/${visit}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/meas1/${meas1}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/meas2/${meas2}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/meas3/${meas3}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/meas4/${meas4}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/meas5/${meas5}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/val1/${val1}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/val2/${val2}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/val3/${val3}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/val4/${val4}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/val5/${val5}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/xnat/${xnat}/g ${sdir}/${sub}_htmlhdr.txt
sed -i s/\>tr\</\>${tr}\</g ${sdir}/${sub}_htmlhdr.txt
