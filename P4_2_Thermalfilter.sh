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
	x=2 #to add line number in the file - 2 because 1st line is used for info
	echo "Site=${Site} - Integrator=${Integrator}" > ${DoneFolder}/${flight}
		for line in $(cat $files | grep "^[0-9]") 
			do
				b=$(echo $line | cut -d ',' -f 3)

				c=$(($b - $a))
			 	echo "${line},$c,$x" >> ${DoneFolder}/${flight}
				a=$b
				x=$((x+1))
			done
done

###################     Thermal filter      #######################

read -p 'Would you like to keep only thermals that last more than a specific time: [Y / N]:' Resp1
		if [ ${Resp1} == 'Y' ]
			then
				
				# Ask user for a thermal duration et take into account the integration time
				read -p 'Enter a minimum time of ascending duration in seconds:' Therm_Time_abs
				Therm_Time_rel=$(echo "${Therm_Time_abs}/${Integrator}" | bc -l)
				Therm_Time_rel=${Therm_Time_rel%.*}
				# Create thermal folder
			
				ThermalFolder=$Syride/$Site/${Site}"_thermal_"${Therm_Time_abs}
				if [ ! -d "$ThermalFolder" ];then mkdir $ThermalFolder; fi
				for files in ${DoneFolder}/*
					do
						flight=$(basename $files)
						LineNumInt=$(wc -l < $files)
						a=0
						b=0
						c=0
						for line in $(cat $files) 
							do
									a=$(echo $line | cut -d ',' -f 4)
									x=$(echo $line | cut -d ',' -f 5)
									if [ $a -gt 0 ];then b=$((b+1));else c=$((c+1)); fi
									if [ $c -gt 0 ];then b=0 c=0 ; fi
									if [ $b -gt ${Therm_Time_rel} ]
										then 
											b=0 
											c=0  
											y=$((x - ${Therm_Time_rel}))
											sed -n ${y},${x}p ${files} >> ${ThermalFolder}/${flight}
											echo "${line}" >> ${ThermalFolder}/${flight}
									fi
									

							done
							LineNumberTherm=$(wc -l < ${ThermalFolder}/${flight})
							echo "flight: ${flight} -  Number of line before= ${LineNumInt} - Number of line after= ${LineNumberTherm}"
						done
			
			
			
				else 
					exit
				fi





