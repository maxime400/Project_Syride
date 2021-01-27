#!/bin/bash

export PGPASSWORD='0056'

Syride="$HOME/Project/Project_Syride"

read -p 'Please enter an existing Site name :' Site

DoneFolder=${Syride}/${Site}/${Site}"_thermal_120" 

while [ ! -d $DoneFolder ]
	do
		echo "${Site}"'_Process doesnt exist'
		read -p 'Please enter an existing Site name :' Site
		DoneFolder=${Syride}/${Site}/${Site}"_thermal_120" 
	done


	#mysql -u maxime -pMassul_43 -D USE syride << EOF 2>&1 >/dev/null
	#mysql -u root -D USE syride << EOF 2>&1 >/dev/null
	psql -d syride -U maxime << EOF
	
	CREATE TABLE IF NOT EXISTS ${Site} (
    longitude FLOAT NOT NULL,
    latitude FLOAT NOT NULL,
    elevation SMALLINT,
    vario SMALLINT,
    id SMALLINT
)

EOF


for files in ${DoneFolder}/*
	do
	sed -i '' '1,2d' ${files}	#Remove the 2 first line because not appropriate for interpretation in QGIS
	#mysql -u root -D USE syride << EOF 2>&1 >/dev/null
	psql -d syride -U maxime << EOF

	
	COPY ${Site} FROM '$files' (DELIMITER(','));

EOF

	#rm $files
	done


