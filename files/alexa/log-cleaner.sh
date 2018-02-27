#!/bin/bash

LOG_FOLDER="{{ log_path }}"

bytes=$(du -d1 ${LOG_FOLDER} | awk '{print $1}')
while [ $bytes -gt 100000 ] ; do
	file="${LOG_FOLDER}/$(ls ${LOG_FOLDER} | head -1)"
	echo "Deleting $file"
	sudo rm $file
	bytes=$(du -d1 ${LOG_FOLDER} | awk '{print $1}')
done