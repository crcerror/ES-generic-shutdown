#!/bin/bash
# Multi Switch Shutdown
# based on ES shutdown codes posted by @cyperghost and @meleu
# v0.05 Initial version here in this repo Jan.2018 // cyperghost
# v0.07 added kill -9 switch to get rid off all emulators // julenvitoria
# v0.10 version for NESPi case // Yahmez, Semper-5

# Up to now 3 devices are supported!
# 
# NESPIcase! Install raspi-gpio via "sudo apt install raspi-gpio", no sudo needed, reset, poweroff
# Mausberry! Script needs to be called with sudo, poweroff supported
# SHIMOnOff! Script needs to be called with sudo, poweroff supported

# ---------------------------------------------------------------------------------------------
# --------------------------------- P I D   D E T E C T I O N ---------------------------------
# ---------------------------------------------------------------------------------------------

# This function is called still all childPIDs are found
function get_childpids() {
    local CPIDS="$(pgrep -P $1)"
    for cpid in $CPIDS; do
        pidarray+=($cpid)
        get_childpids $CPIDS
    done
}

# Abolish sleep timer! This one is much better!
function wait_forpid() {
    local PID=$1
    while [[ -e /proc/$PID ]]; do
        sleep 0.10
    done
}

# This will reverse ${paidarray} array and close all emulators
# This function needs a valid pidarray
function close_emulators() {
    for ((z=${#pidarray[*]}-1; z>-1; z--)); do
        kill -9 ${pidarray[z]}
        wait_forpid ${pidarray[z]}
    done
}

# Emulator currently running?
# If yes return PID from runcommand.sh
# due caller funtion
function check_emurun() {
    local RC_PID="$(pgrep -f -n runcommand.sh)"
    echo $RC_PID
}

# Emulationstation currently running?
# If yes return PID from ES binary
# due caller funtion
function check_esrun() {
    local ES_PID="$(pgrep -f "/opt/retropie/supplementary/.*/emulationstation([^.]|$)")"
    echo $ES_PID
	}

# ---------------------------------------------------------------------------------------------
# ------------------------------------ E S - A C T I O N S ------------------------------------
# ---------------------------------------------------------------------------------------------

# This function can be called as several parameters 
# if it is called empty then a poweroff will performed
# es-shutdown, will close ES and force an poweroff
# es-sysrestart, will close ES and force an reboot
# es-restart, will close ES and restart it
function es_action() {
    local ES_FILE=$1
    [[ -z $ES_FILE ]] && ES_FILE="es-shutdown"
    ES_PID="$(check_esrun)"
    touch /tmp/$ES_FILE
    chown pi:pi /tmp/$ES_FILE
    kill $ES_PID
    [[ $ES_FILE == "es-restart" ]] || exit
}

# ---------------------------------------------------------------------------------------------
# ----------------------------------- S W I T C H T Y P E S -----------------------------------
# ---------------------------------------------------------------------------------------------


# ------------------------------------- N E S P I C A S E -------------------------------------

# NESPI CASE @Yahmez Mod
# https://retropie.org.uk/forum/topic/12424
# Defaults are:
# ResetSwitch GPIO 23, input, set pullup resistor!
# PowerSwitch GPIO 24, input, set pullup resistor!
# PowerOnControl GPIO 25, output, high

function NESPiCase(){
    #Set GPIOs
    [[ -n $1 ]] && GPIO_resetswitch=$1 || GPIO_resetswitch=23
    [[ -n $2 ]] && GPIO_powerswitch=$2 || GPIO_powerswitch=24
    [[ -n $3 ]] && GPIO_poweronctrl=$3 || GPIO_poweronctrl=25

    # Init: Use raspi-gpio to set pullup resistors!
    raspi-gpio set $GPIO_resetswitch ip pu
    raspi-gpio set $GPIO_powerswitch ip pu
    raspi-gpio set $GPIO_poweronctrl op dh

    until [[ $power == 0 ]]; do
        power=$(raspi-gpio get $GPIO_powerswitch | grep -c "level=1 fsel=0 func=INPUT")
        reset=$(raspi-gpio get $GPIO_resetswitch | grep -c "level=1 fsel=0 func=INPUT")

        if [[ $reset == 0 ]]; then
            RC_PID=$(check_emurun)
            [[ -z $RC_PID ]] && es_action es-restart
            [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
        fi

    sleep 1
done

# Initiate Shutdown per ES
RC_PID=$(check_emurun)
[[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
wait_forpid $RC_PID
es_action es-shutdown
}

# ------------------------------------- M A U S B E R R Y -------------------------------------

# Mausberry original script by mausershop
# Sudo command needed
# https://mausberry-circuits.myshopify.com/pages/setup
# Defaults are:
# PowerSwitch GPIO 23, input, export via bash
# PowerOnControl GPIO 24, output, export high via bash

function Mausberry() {

    #Set GPIOs
    #this is the GPIO pin connected to the lead on switch labeled OUT
    [[ -n $1 ]] && GPIO_powerswitch=$1 || GPIO_powerswitch=23
    #this is the GPIO pin connected to the lead on switch labeled IN
    [[ -n $3 ]] && GPIO_poweronctrl=$2 || GPIO_poweronctrl=24

    echo "$GPIO_powerswitch" > /sys/class/gpio/export
    echo "in" > /sys/class/gpio/gpioGPIO_powerswitch/direction
    echo "GPIO_poweronctrl" > /sys/class/gpio/export
    echo "out" > /sys/class/gpio/gpio$GPIO_poweronctrl/direction
    echo "1" > /sys/class/gpio/gpio$GPIO_poweronctrl/value

    while [ 1 = 1 ]; do
        power=$(cat /sys/class/gpio/gpio$GPIO_powerswitch/value)
            if [ $power = 0 ]; then
                sleep 1
            else
                RC_PID=$(check_emurun)
                [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
                wait_forpid $RC_PID
                es_action es-shutdown
            fi
     done
}

# ------------------------------------- O N O F F S H I M -------------------------------------

# Pimoroni SHIM ON OFF
# https://retropie.org.uk/forum/topic/15727
# Sudo command needed
# systemd shutoff needed! See forum post! This uses GPIO 4
# modified scripts by cyperghost
# Defaults are:
# PowerSwitch GPIO 17, input, export via bash
# PowerOnControl GPIO 4, ouput, high, setted low for shutdown!

function OnOffShim() {

    #Set GPIO
    #This is the GPIO pin connected to the lead on switch labeled BCM17:Status
    #PowerOnControl will be shutoff by systemd - read forum post!!
    [[ -n $1 ]] && GPIO_powerswitch=$1 || GPIO_powerswitch=17

    echo $trigger_pin > /sys/class/gpio/export
    echo in > /sys/class/gpio/gpio$trigger_pin/direction

    power=$(cat /sys/class/gpio/gpio$trigger_pin/value)

    # Here we can use Momentary and Fixed Switches
    [ $power = 0 ] && switchtype=1 
    [ $power = 1 ] && switchtype=0 

    until [ $power = $switchtype ]; do
        power=$(cat /sys/class/gpio/gpio$trigger_pin/value)
        sleep 1
    done

    # Initiate Shutdown per ES
    RC_PID=$(check_emurun)
    [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
    wait_forpid $RC_PID
    es_action es-shutdown
}


# ---------------------------------------------------------------------------------------------
# ------------------------------------------ M A I N ------------------------------------------
# ---------------------------------------------------------------------------------------------

ES_PID=$(check_esrun)
echo $ES_PID

# NESPiCase with mod by Yahmez
# https://retropie.org.uk/forum/topic/12424
# Defaults are:
# ResetSwitch GPIO 23, input, set pullup resistor!
# PowerSwitch GPIO 24, input, set pullup resistor!
# PowerOnControl GPIO 25, output, high
# Enter other BCM connections to call
NESPiCase 23 24 25

# Mausberry original script by mausershop
# Sudo command needed
# https://mausberry-circuits.myshopify.com/pages/setup
# Defaults are:
# PowerSwitch GPIO 23, input, export via bash
# PowerOnControl GPIO 24, output, export high via bash
# Mausberry 23 24

# Pimoroni SHIM ON OFF
# https://retropie.org.uk/forum/topic/15727
# Sudo command needed
# systemd shutoff needed
# modified scripts by cyperghost
# Defaults are:
# PowerSwitch GPIO 17, input, export via bash
# PowerOnControl GPIO 4, ouput, high, setted low for shutdown!
# OnOffShim 17 4
