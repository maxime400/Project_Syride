#!/bin/bash


#Return in terminal 

#FlightNumber=$1

Directory="/Volumes/Syride_RAW/AllSyride"


FirstFile=$(find $Directory -type f | sort -V | head -1)
LastFlNum=$(find $Directory -type f | sort -V | tail -n 1)

echo "First file of the folder AllSyride = ${FirstFile}"

echo "Last file of the folder AllSyride = ${LastFlNum}"

LastFlNum=$(echo ${LastFlNum} | tr -dc '0-9')


