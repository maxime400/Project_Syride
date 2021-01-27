#!/bin/bash

Directory=$1

Total=$(find $Directory/ -type f | wc -l)




echo " There is $Total files in the directory: $Directory"




