#!/bin/bash

echo "testing by scanning this file.."

fo=$(curl -s -F "name=blabla" -F "file=@/testi.sh" 127.0.0.1:8080/scan)



if [ "$fo" != "Everything ok : true" ]
  then
    echo "service not ok.. ($fo)"
    exit -1
   else
   	echo "service ok.. ($fo)" 
fi
