#!/bin/bash

export ALEXA_PATH="$HOME/alexa"
export ALEXA_LOGS_PATHS="$HOME/alexa-logs"
export ALEXA_JAVACLIENT_LOG="$ALEXA_LOGS_PATHS/javaclient.log"
export ALEXA_WAIT_TIME=120
export ALEXA_PS_JAVACLIENT="classpath /home/pi/alexa/samples/javaclient"
export ALEXA_PS_COMPANION="bin/www"

_psName2Ids(){
    ps -aux | grep -i "$1" | awk '{print $2}'
}

_getPid(){
    pid=$(ps -aux | grep "$1" | awk '{print $2}')
    pid=($pid)
    echo "${pid[1]}"
}

_launch_companionService(){
    psKill "$ALEXA_PS_COMPANION"
    cd $ALEXA_PATH/samples/companionService
    npm start >$ALEXA_LOGS_PATHS/companionService.log 2>&1 &
}

_launch_javaclient(){
    echo "First launch: remember to see '$ALEXA_JAVACLIENT_LOG' to log in Alexa VCS."
    psKill "$ALEXA_PS_JAVACLIENT"
    cd $ALEXA_PATH/samples/javaclient
    if [ "$1" == "--attach" ]; then
        mvn exec:exec
    else
        mvn exec:exec >$ALEXA_JAVACLIENT_LOG 2>&1 &
    fi
}


_launch_wakeWordAgent(){
    cd $ALEXA_PATH/samples/wakeWordAgent/src
    ./wakeWordAgent -e sensory >$ALEXA_LOGS_PATHS/wakeWordAgent.log 2>&1 &
}

_wait_and_launch(){

    command=$(echo "source $HOME/alexa-cli.sh && sleep $ALEXA_WAIT_TIME && $@")
    bash -c "$command" & # auto-expire auth server

}

_checkAgentAlive(){

    # if there is wakeWordAgent, ensure it is working
    wakeWordAgentPs=($(_psName2Ids wakeWordAgent))
    if [ ${#wakeWordAgentPs[@]} -ne 2 ]; then
        psKill wakeWordAgent
        _launch_wakeWordAgent
    fi;
    _wait_and_launch _checkAgentAlive

}

########################################################################################################################

psKill(){
    _psName2Ids $1 | xargs kill -9 > /dev/null 2>&1
}

checkAlive(){

    psKill _checkAgentAlive

    javaclientPs=($(_psName2Ids "$ALEXA_PS_JAVACLIENT"))
    companionPs=($(_psName2Ids "$ALEXA_PS_COMPANION"))
    # keep Alexa app alive
    if [ ${#javaclientPs[@]} -le 1 ] || [ ${#companionPs[@]} -le 1 ]; then
        lauch_alexa "$@"

         # if there is wakeWordAgent, launch it
        if [ -f $ALEXA_PATH/samples/wakeWordAgent/src/wakeWordAgent ]; then
            echo "wakeWordAgent will be launched in $ALEXA_WAIT_TIME seconds."
            _wait_and_launch _checkAgentAlive
        fi;
    fi;

    errors=$(cat $ALEXA_JAVACLIENT_LOG | grep "com.amazon.alexa.avs.http.AVSClient - There was a problem with the request.")
    if [ "$errors" != "" ]; then
        echo "command ->" >> $ALEXA_JAVACLIENT_LOG
        pid=$(_getPid $ALEXA_PS_JAVACLIENT)
        echo "en-GB" > $(echo "/proc/$pid/fd/0")
    fi
}


# --attach
lauch_alexa(){
    _launch_companionService
    _launch_javaclient "$@"
}
