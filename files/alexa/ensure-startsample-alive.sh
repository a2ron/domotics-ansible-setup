#!/bin/bash

LOG_FOLDER="{{ log_path }}"

_psName2Ids(){
    ps -aux | grep -i "$1" | awk '{print $2}'
}

psKill(){
     _psName2Ids $1 | xargs sudo kill -9 > /dev/null 2>&1;
}

findError(){
    cat ${LOG_FOLDER}/$(ls ${LOG_FOLDER} | tail -1)  | grep "$1" | wc | awk '{print $1}'
}

# check errors
error1=$(findError "AbstractKeywordDetector")
error2=$(findError "RequiresShutdown")

processes=($(_psName2Ids "startsample.sh"))
if [ {{ '${#processes[@]}' }} -le 1 ] || [ $error1 -gt 10 ] || [ $error2 -gt 0 ] ; then

    now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    sudo touch "$LOG_FOLDER/$now.log"
    sudo chmod go+rwx "$LOG_FOLDER/$now.log"
    cd "{{ install_path }}"
    psKill "startsample.sh"

    screen -L "$LOG_FOLDER/$now.log" -dm sudo bash startsample.sh
fi;

# schedulle other check if flag -r present
if [ "$1" == "-r" ] ; then
        bash -c "sudo sleep 30; {{ install_path }}/ensure-startsample-alive.sh" &
fi
