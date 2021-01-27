#!/bin/bash


#Return a text file including all file number of syride files in allSyride folder.

for files in $HOME/Documents/prive/project_syride/AllSyride/AllSyride2/*
do

Number=$(echo $files | tr -dc '0-9')
echo "$Number" >> /home/ecgs/Documents/prive/project_syride/CurentAllSyride2Number.txt


done

sort -h /home/ecgs/Documents/prive/project_syride/CurentAllSyride2Number.txt





