# ES-generic-shutdown
A script that includes a few known standard power switches (MAUSBERRY, SHIM, POLOLU) and gots a default config for a safe shutdown.

## NESPi+ Instructions!

**This case rocks! It really can totally shutoff power! But we need to edit some service files!**
* First: install raspi-gpio with `sudo apt install raspi-gpio`
* Second: install shutdown_fan script as descriped in point 6
* Today (03/05/18) I got a NESPi+ case so I was able to elaborate the issue. Thanks to gollumer for your patince!

0. Set NESPi+ case switch to safe shutdown *ON*
1. Login with SSH
2. Type in commands `mkdir /home/pi/RetroPie/scripts && cd /home/pi/RetroPie/scripts`
3. DL: `wget https://raw.githubusercontent.com/crcerror/ES-generic-shutdown/master/multi_switch.sh && chmod +x multi_switch.sh`
    * 3.1 If there is an older version please remove this one with `rm multi_switch.sh`
    * 3.2 Otherwise the current downloaded version will get a .sh.1 filename!
4. Now edit ES autostart with `nano /opt/retropie/configs/all/autostart.sh` and add script to like ....
5. `/home/pi/RetroPie/scripts/multi_switch.sh --nespi+ &` but BEFORE the last line *emulationstatio #auto*   
6. Install fan_shutdown script: `cd /lib/systemd/system-shutdown/ && sudo wget https://raw.githubusercontent.com/crcerror/ES-generic-shutdown/master/shutdown_fan && sudo chmod +x shutdown_fan`
    * 6.1 The shutdown_fan is setted to GPIO4 as standard
    * 6.2 Therefore you might edit with `sudo nano /lib/systemd/system-shutdown/shutdown_fan`
    
## The [MultiSwitch - ShutdownScript](https://github.com/crcerror/ES-generic-shutdown/blob/master/multi_switch.sh)

To install:
1. Login with SSH
2. Type in commands `mkdir /home/pi/RetroPie/scripts && cd /home/pi/RetroPie/scripts`
3. DL: `wget https://raw.githubusercontent.com/crcerror/ES-generic-shutdown/master/multi_switch.sh && chmod +x multi_switch.sh`
    * 3.1 If there is an older version please remove this one with `rm multi_switch.sh`
    * 3.2 Otherwise the current downloaded version will get a .sh.1 filename!
4. Now edit ES autostart with `nano /opt/retropie/configs/all/autostart.sh` and add script to like ....
5. `/home/pi/RetroPie/scripts/multi_switch.sh --nespicase &` but BEFORE the last line *emulationstatio #auto*   
    * 5.1 Use suitable parameter sets `--nespicase &`, `--nespi+ &`, `--onoffshim &`, `--mausberry &`
    * 5.2 *NESPiCase @Yahmez -Mod* and *NESPi Case +* makes use of internal PullUp Resistors, therefore `raspi-gpio` is needed
    * 5.3 Install **raspi-gpio** with `sudo apt install raspi-gpio` (only for NESPiCase and Yahmez-Mod needed!)
    * 5.4 the **sudo** commands depends of usecase, Mausberry and OnOffShim needs it for GPIO export, both NESPiCase(+) not
6. Give me some feedback ;)

## Command Line Parameters
**Systemcommand:**

* `--es-pid        Shows PID of ES, if not it shows 0`
* `--rc-pid        Shows PID of runcommand.sh - shows 0 if not found`
* `--es-systemd    Hook for the famous "Gracefully exit with metadata saved"-Service by @meleu`
* `--es-closeemu      Tries to shutdown emulators, with cyperghost method`
* `--es-poweroff   Shutdown emulators (if running), Closes ES, performs poweroff`
* `--es-reboot     Shutdown emulators, Cloese ES, performs system reboot`
* `--es-restart  Shutdown emulators (if running), Restart ES`

**SwitchDevices:**

* `--mausberry     If you have a Mausberry device, GPIO 23 24 used!`
* `--onoffshim     If you have the Pimoroni OnOff SHIM GPIO 17 and 4 used!`
* `--nespicase     If you use the NESPICASE with yahmez-mod GPIO 23 24 25 used!`
* `--nespi+        If you use the NESPI+ CASE original from RetroFlag GPIO 2 3 4 14 used!`
* `--generic     You can use latching and momentary button for this connected to any GPIO and common ground, default is GPIO 3 as only this provides powerdown and repower ability`

## I added system parameter commands now

```
Created command line parameters
We can now call specific commands out of every programming language

Systemcommand:

--es-pid        Shows PID of ES, if binary of ES can't be found it returns 0
--rc-pid        Shows PID of runcommand.sh, that's usefull to detect emulators running
--closeemu      Tries to shutdown emulators, with cyperghost method
--es-poweroff   Shutdown emulators (if running), Closes ES, performs poweroff
--es-reboot     Shutdown emulators, Closes ES, performs system reboot
--es-restart    Shutdown emulators (if running), Restart ES

SwitchDevices:

--mausberry     If you have a Mausberry device, GPIO 23 24 used!
--onoffshim     If you have the Pimoroni OnOff SHIM GPIO 17 and 4 used!
--nespicase     If you use the NESPICASE with yahmez-mod GPIO 23 24 25 used!
--nespi+        If you use the regular NESPi+ Case, GPIO 2 3 4 14 are used!
```

## Setup your GPIOs via commandline

Up to now 4 parameters are supported
1. `powerbtn=` with this command you set desired GPIO the **powerbutton** is attached to. If you left unsigned or you enter wrong setting, then default values are used. All devices support that command
2. `resetbtn=` with this command you set desired GPIO the **resetbutton** is attached to. If you left unsigned or you enter wrong setting, then default values are used. Only the both NESPi cases supports that type. So if you use this command on a generic button it will be ignored!
3. `powerctrl=` with this command you set desired GPIO the **power ON control** is attached to. All devices needs this, except the generic button only! If you enter wrong values or leave it blank the default values for expected device are used. This command indicates the power device in which state the Raspberry is, so a complete power cut can be performed!
4. `ledctrl=` with this command you set desired GPIO a **LED can be shut ON or OFF**. Up to now only the NESPi cases supports that feature. I think I can integrate it to other devices, too.

So you set for example your Mausberry-switch via commandline:
1. default values: `multi_switch.sh --mausberry` this will use **GPIO23 for power button** and **GPIO24 for power ON control**.
2. `multi_switch.sh --mausberry powerbtn=17` this will use **GPIO17 for power button** and **GPIO24 for power ON control** still as default
3. `multi_switch.sh --mausberry powerctrl=4 powerbtn=3` this will use **GPIO3 for power button** and **GPIO4 for power ON control**
4. `multi_switch.sh --mausberry powerbutton=3 powerctrl=3a` will use default values **GPIO23 for power button** and **GPIO24 for power ON control** as parameters were all setted wrong (It should be **powerbtn not powerbutton** and only integers are accepted so **powerctrl=3a** is not accepted).

This script provides support for 5 devices now. More to come with help from others! So this bash script uses some function calls that may be usefull for extended usecases. 

# Todo:
* ~~We are missing dkpg-check for package~~ (done in v0.32)
* ~~sudo user check~~ (done in v0.32)
* config files
