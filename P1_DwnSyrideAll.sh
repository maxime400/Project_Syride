#!/bin/sh

#Lecture du dernier fichier téléchargé

Px1="$HOME/Project/Project_Syride/Px1_LastDownload.txt"
StartNum=$(cat $HOME/Project/Project_Syride/Px1_LastDownload.txt)
ErrorFile="$HOME/Project/Project_Syride/Px1_Error.txt"
Directory="/Volumes/Syride_RAW/AllSyride"
LastFlNum=""

if [ ! -d ${Directory} ]
 	then
 		'Please plug the Volume Syride_RAW or check if the Directory "AllSyride" exist'
 		exit
fi

if [ ! -z ${ErrorFile} ]
	then	
		chmod 666 ${ErrorFile}
		echo " There was an issue at the last download -->  last file theoretically downloaded is : ${StartNum}"
		read -p 'Do you want to continue from this file without verifying [Y / N]:' Resp1
		if [ ${Resp1} == 'Y' ]
			then
				rm -f ${ErrorFile}
				echo "remove error file : ${ErrorFile}"
				echo "$StartNum"
		elif [ ${Resp1} == 'N' ]
			then
				LastFlNum=0
				. /Users/maxime/Project/Project_Syride/T_ReadTopBotFileName.sh 	
				echo " The last flight number checked in the Syride Raw Files is : ${LastFlNum}"
				read -p 'Do you want to write this new value in the Px1_LastDownload.txt:  [Y / N]:' Resp2
				if [ ${Resp2} == 'Y' ]
					then
						echo "${LastFlNum}" >${Px1}
						StartNum=${LastFlNum}
						rm -f ${ErrorFile}
				elif [ ${Resp2} == 'N' ]
					then
						echo "The last flight number read in Syride RAW is ${LastFlNum} - but we are going to start from the ${StartNum} "	
				
				else 
					"Wrong entered value"
					exit
				fi
		else 
				"Wrong entered value"
				exit
		fi
fi
			
sleep 5
if [ $StartNum -gt 999999 ] &&  [ $StartNum -lt 999999 ] && [ ! -e ${ErrorFile} ]
	then

	echo " we are starting to download from the flight number $StartNum "
	sleep 5

	for i in `seq  $StartNum 999999`
		do
		file=/Volumes/Syride_RAW/AllSyride/VolSyride$i 2>$ErrorFile

		wget -q https://www.syride.com/scripts/downloadKML.php?idSession=$i -O $file 2>$ErrorFile

		#echo $file
		echo $i > $HOME/Project/Project_Syride/Px1_LastDownload.txt 2>${ErrorFile}

		# Affichage dans la console du dernier fichier téléchargé multiple de 1000
		k=$(( i % 1000 ));
		[ "$k" -eq 0 ] && echo " File $i downloaded --> file name is $file"

	done

else
	
	echo "We have an issue with the last file downloaded in the file ${ErrorFile}" 2>${ErrorFile}
	echo "We have an issue with the last file downloaded in the file ${ErrorFile}"
		chmod 777 ${ErrorFile}
fi
