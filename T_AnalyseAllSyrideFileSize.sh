#!/bin/bash


#Return in terminal 



for files in $HOME/Documents/prive/project_syride/AllSyride/AllSyride2/*
do
sleep 1
#FILESIZE=$(stat -c%s "$files")

FILESIZE=$(ls -la $files)
Number=$(echo $files | tr -dc '0-9')
echo "file number $Number = $FILESIZE" 


done







