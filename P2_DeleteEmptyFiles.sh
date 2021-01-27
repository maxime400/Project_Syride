#!/bin/bash

SyrideRaw='/Volumes/Syride_RAW/AllSyride/'


Total=$(find $SyrideRaw -type f | wc -l)

Empty=$(find $SyrideRaw -type f -empty | wc -l)


echo " There is $Empty files empty on a total of $Total.. remove all empty in 5 sec"

sleep 5

find $SyrideRaw -type f -empty -delete

Total=$(find $SyrideRaw -type f | wc -l)
Empty=$(find $SyrideRaw -type f -empty | wc -l)

echo " There is $Empty files empty on a total of $Total.. remove all empty in 5 sec"




