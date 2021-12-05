#!/bin/bash
set -e 

####Defining pathways
toplvl=/mnt/d/wangsiyu/Data/Visual_search_task/BIDS
niidir=${toplvl}/Nifti
dcmdir=${toplvl}/Dicom
dcm2niidir=/mnt/d/MRIcroGL_linux/MRIcroGL/Resources

#Create nifti directory
jo -p "Name"="Visual search task difficulty Dataset" "BIDSVersion"="1.0.2" >> ${niidir}/dataset_description.json

for subj in `ls $dcmdir`
do
	echo "Processing subject $subj"

    ####Anatomical Organization####
    ###Create structure mkdir -p 递归创建文件夹
    mkdir -p ${niidir}/sub-${subj}/ses-1/anat
    ###Convert dcm to nii
    #Only convert the Dicom folder anat 
    ${dcm2niidir}/dcm2niix -o ${niidir}/sub-${subj} -f ${subj}_%f_%p ${dcmdir}/${subj}/sT1W*   
    cd ${niidir}/sub-${subj}
    anatfiles=`ls -1 *sT1W_3D* | wc -l`
    for ((i=1;i<=${anatfiles};i++))
    do
        Anat=`ls *sT1W_3D*` #This is to refresh the Anat variable, if this is not in the loop, each iteration a new "No such file or directory error", this is because the filename was changed. 
        tempanat=`echo $Anat | sed '1q;d'` #Capture new file to change
        tempanatext=${tempanat##*.}
        tempanatfile=${tempanat%.*}
        mv ${tempanatfile}.${tempanatext} sub-${subj}_ses-1_T1w.${tempanatext}
        echo "${tempanat} changed to sub-${subj}_ses-1_T1w.${tempanatext}"
    done 
    ###Organize files into folders
    for files in `ls sub*`
    do 
        Orgfile=${files%.*}
        Orgext=${files##*.}
        Modality=`echo $Orgfile | rev | cut -d '_' -f 1 | rev`
        if [ $Modality = "T1w" ] 
        then
    	    mv ${Orgfile}.${Orgext} ses-1/anat
        fi 
    done

    ####Functional Organization####
    #Create subject folder
    mkdir -p ${niidir}/sub-${subj}/{ses-1,ses-2,ses-3,ses-4,ses-rs}/func    
    ###Convert dcm to nii
    for direcs in `ls ${dcmdir}/${subj}| grep -E '*FEEPI*'` 
    do
        ${dcm2niidir}/dcm2niix -o ${niidir}/sub-${subj} -f ${subj}_${direcs}_%p ${dcmdir}/${subj}/${direcs}
    done
    #Changing directory into the subject folder
    cd ${niidir}/sub-${subj}
    ##Rename func files
    #Break the func down into each task
    #Visual search task
    vsfiles=`ls -1 *FEEPI_VS* | wc -l`
    for ((i=1;i<=${vsfiles};i++))
    do
        vser=`ls *FEEPI_VS*|sort -t '_' -nk 5` #This is to refresh the Checker variable, same as the Anat case
        tempvs=`echo $vser | sed '1q;d'` #Capture new file to change
        tempvsext=${tempvs##*.}
        tempvsfile=${tempvs%.*}
        TR=$[ (i+1)/2 ] 
        mv ${tempvsfile}.${tempvsext} sub-${subj}_ses-${TR}_task-visualsearch_bold.${tempvsext}
        echo "${tempvsfile}.${tempvsext} changed to sub-${subj}_ses-${TR}_task-visualsearch_bold.${tempvsext}"
        if [ $tempvsext = 'json' ]
        then
            sed -i '1a \\t"TaskName":"visualsearch",' sub-${subj}_ses-${TR}_task-visualsearch_bold.${tempvsext}
           else
            :
        fi
    done
    #Rest 
    rsfiles=`ls -1 *FEEPI_rs12* | wc -l`
    for ((i=1;i<=${rsfiles};i++))
    do
        rser=`ls *FEEPI_rs12*` #This is to refresh the Checker variable, same as the Anat case
        temprs=`echo $rser | sed '1q;d'` #Capture new file to change
        temprsext=${temprs##*.}
        temprsfile=${temprs%.*} 
        mv ${temprsfile}.${temprsext} sub-${subj}_ses-rs_task-visualsearch_bold.${temprsext}
        echo "${temprsfile}.${temprsext} changed to sub-${subj}_ses-rs_task-visualsearch_bold.${temprsext}"
        if [ $temprsext = 'json' ]
        then
            sed -i '1a \\t"TaskName":"rest",' sub-${subj}_ses-rs_task-visualsearch_bold.${temprsext}
           else
            :
        fi
    done

    ###Organize files into folders
    for files in $(ls sub*)
    do 
        Orgfile=${files%.*}
        Orgext=${files##*.}
        Sessionnum=`echo $Orgfile | cut -d '_' -f2`
    	mv ${Orgfile}.${Orgext} ./$Sessionnum/func
    done

done