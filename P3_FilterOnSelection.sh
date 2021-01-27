#!/bin/sh

read -p " Would you like to search in the entire database? [Y/N]" DataSource
	if [ $DataSource == "Y" ]
		then
			SourceSyride='/Volumes/Syride_RAW/AllSyride'
		elif [ $DataSource == "N" ]
			then
				read -p " Please enter a site name (the process will search in the RAW data)" DataSourceSite
				if [ ! -e ${HOME}/Project/Project_Syride/${DataSourceSite}/${DataSourceSite}_RAW ]
					then
						echo "No data source found for ${DataSourceSite} --> stop process" 
						exit
				fi
				SourceSyride="${HOME}/Project/Project_Syride/${DataSourceSite}/${DataSourceSite}_RAW"
		else
			echo 'error'
			exit
	fi
	
read -p 'Please enter a Site name :' SiteName

SiteFolder=${HOME}/Project/Project_Syride/${SiteName}

FolderRaw=${SiteFolder}/${SiteName}"_RAW"
if [ ! -d ${SiteFolder} ]
	then
		echo "Folder doesnt exist: create it here: $TakeoffFolder"
		mkdir ${SiteFolder}
		mkdir ${FolderRaw}
		Continuation="No"
	else
		read -p " ${SiteName} already exist, would you continue a started process? [Yes/No]" Continuation
fi

# Put in variables the coordinates of a takeoff area.
files=$HOME/Project/Project_Syride/Px3_selection.csv
DataXY=$(cat $files | grep ${SiteName})

if [ -s ${DataXY} ]
	then
		echo 'No data for this site in Px3_selection.csv --> stop process' 
		exit
fi

echo $DataXY

X1=`echo "${DataXY}" | awk -F',' '{print$1}'`
Y1=`echo "${DataXY}" | awk -F',' '{print$3}'`

X2=`echo "${DataXY}" | awk -F',' '{print$2}'`
Y2=`echo "${DataXY}" | awk -F',' '{print$4}'`

echo "Square: X1= $X1   ___ Y1= $Y1"
echo "Square: X2= $X2   ___ Y2= $Y2"



i=1
j=0
FileNumber=$(find ${SourceSyride} -type f | wc -l)

echo ${FileNumber}


#--------------------Start-----------------------------------

if [ $Continuation == "No" ]
then echo 'Lets start the run of the entire Syride flight database folder to see which files is in the seleced area.'

echo ${SourceSyride}




for files in ${SourceSyride}/*
do

Xtar=$(cat ${files} | grep ^[0-9]\.* | head -n 1 | cut -d ',' -f 1)
Ytar=$(cat ${files} | grep ^[0-9]\.* | head -n 1 | cut -d ',' -f 2)

#echo $Xtar 
#echo $Ytar
# sed -i 1,13d $files
# 
# Xtar=`head -n 1 $files | awk -F',' '{print$1}'`
# Ytar=`head -n 1 $files | awk -F',' '{print$2}'`

#echo "For files $files, here is the coordonate of 1st position"
#echo "X=$Xtar   ___ Y=$Ytar"


if [[ "$Xtar" > "$X1" ]] && [[ "$Xtar" < "$X2" ]] && [[ "$Ytar" > "$Y1" ]] && [[ "$Ytar" < "$Y2" ]] 
then
cp $files ${FolderRaw}/
j=`expr $j + 1`
echo " This files $i in the square"
#else
#echo " This files $i is NOT in the square"
fi


k=$(( i % 1000 ));
[ "$k" -eq 0 ] && echo " File $i treated on $FileNumber number of files"



#if [ ${k: -1} -eq 000 ]
#then
#echo " File $i treated on $FileNumber number of files"
#fi

i=`expr $i + 1`


done

echo " On a total of $FileNumber files in the database, $j files are in the square."


#-----------------------End First Run-------------------------------

elif [ $Continuation == "Yes" ]
then echo "Let's check first if the file is already in $TakeoffFolder, and if not compare with the selected area"

for files in ${SourceSyride}/*
do
bfiles=$(basename ${files})

if [ ! -f ${FolderRaw}/$bfiles ]
then
	Xtar=$(cat ${files} | grep ^[0-9]\.* | head -n 1 | cut -d ',' -f 1)
	Ytar=$(cat ${files} | grep ^[0-9]\.* | head -n 1 | cut -d ',' -f 1)

	# sed -i 1,13d $files
# 	Xtar=`head -n 1 $files | awk -F',' '{print$1}'`
# 	Ytar=`head -n 1 $files | awk -F',' '{print$2}'`
		if [[ "$Xtar" > "$X1" ]] && [[ "$Xtar" < "$X2" ]] && [[ "$Ytar" > "$Y1" ]] && [[ "$Ytar" < "$Y2" ]] 
		then
		cp $files ${FolderRaw}/
		j=`expr $j + 1`
		echo " This files $i in the square"
		fi
	k=$(( i % 1000 ));
	[ "$k" -eq 0 ] && echo " File $i treated on $FileNumber number of files"
	i=`expr $i + 1`
fi
done
echo " On a total of $FileNumber files in the database, $j files have been added in the square."
#-----------------------End Continuation Run-------------------------------
else
echo "You didn't right the Yes or No when asked"
echo ""
echo "Script stopped"
fi

