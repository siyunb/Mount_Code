#!/bin/bash
set -e 

####Defining pathways
toplvl=/mnt/d/wangsiyu/Data/Visual_search_task/BIDS
ordcmdir=/mnt/g/raw-data
tsdcmdir=${toplvl}/Dicom
fmridir=/mnt/g/fmri

####Transfer Dicom####
i=1
for subj in `ls $fmridir`
do
	echo "Processing subject $subj"
    ###Create structure mkdir -p 递归创建文件夹
    mkdir -p ${tsdcmdir}/$(printf "%02d\n" $i)
    cp ${ordcmdir}/${subj}/*VS*.zip ${tsdcmdir}/$(printf "%02d\n" $i)
    cd ${tsdcmdir}/$(printf "%02d\n" $i)
    unzip *VS*.zip
    rm *VS*.zip
    mv ./*VS*/*2019*/* .
    rm -rf *VSearch*
    i=$[ i+1 ]
done