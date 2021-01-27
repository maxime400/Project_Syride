#!/bin/bash



###################     Variable definition      #######################
echo "Variable definition, folder creation if needed and count the number of files"

Syride="$HOME/Project/Project_Syride"


read -p 'Please enter a site name:' Site
read -p 'Please enter a vario integration number:' Integrator


RAWFolder=$Syride/$Site/${Site}"_RAW" 


while [ ! -d $RAWFolder ]
do
		echo "$Site"'_RAW doesnt exist'
		read -p 'Please enter an existing site name :' Site
		RAWFolder=$Syride/$Site/${Site}"_RAW" 
done

#Create output directory
DoneFolder=$Syride/$Site/${Site}"_done"
ProcessFolder=$Syride/$Site/${Site}"_process"


if [ ! -d "$ProcessFolder" ];then mkdir $ProcessFolder; fi
if [ ! -d "$DoneFolder" ];then mkdir $DoneFolder; fi


# Count the number of file 
TotalFiles=`ls $RAWFolder | wc -l`
count=${TotalFiles}
echo "There are $TotalFiles files in the RAW folder"

###################     Integration treatment      #######################
echo "Apply the integration by keeping only 1 line every integration number in the file move the result in process folder"

# Copy the file from Raw and keep only 1 line per number of integrator

for files in ${RAWFolder}/*
do
	flight=$(basename ${files})
	LineNum=$(wc -l < ${files})
	timeofflight=$((${LineNum}/60))
	echo "There is ${LineNum} line in the file and this flight should have lasted ${timeofflight} minutes "
	#sed -i '' '1,13d' ${files}	#Cut the 12 first line of the file
	i=1
	j=14	# Because the 13 first line of the kml file is the head of the file (no need to cut with sed)
	echo "Site=${Site} \- Integrator=${Integrator}" > ${ProcessFolder}/${flight}
	while [[ ${j} -le ${LineNum} ]]
		do
			head -${j} ${files} | tail -1 >> ${ProcessFolder}/${flight}
			j=$(( $j + ${Integrator} ))
		done
done




###################     Vario delta calculation      #######################
echo "Calculate the vario between each points and add the value at each line, move the result in process folder"

for files in ${ProcessFolder}/*
do
	dos2unix -k $files >> /dev/null  #Change to ASCII text without CLRF line terminator
	a=0
	LineNumber=$(wc -l < $files)
	count=$((count-1))
	echo "$count/$TotalFiles -- $(basename $files) as $LineNumber lines: $(date +%H:%M:%Ss)" 
	#echo "Working on the file $files : this file as $LineNumber lines: $(date +%H:%M:%Ss)"
	#FileShort=`echo "$files" | awk -F'/' '{print$NF}'`
	flight=$(basename $files)
	echo "Site=${Site} - Integrator=${Integrator}" > ${DoneFolder}/${flight}
		for line in $(cat $files | grep "^[0-9]") 
			do
				b=$(echo $line | cut -d ',' -f 3)

				c=$(($b - $a))
			 	echo "${line},$c" >> ${DoneFolder}/${flight}
				a=$b
			done
done	






