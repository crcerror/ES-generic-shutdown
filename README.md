# ES-generic-shutdown
A script that includes a few known standard power switches (MAUSBERRY, SHIM, POLOLU) and gots a default config for a safe shutdown.

## NESPi+ Instructions!

**This case rocks! It really can totally shutoff power! But we need to edit some service files!**
First: install raspi-gpio with `sudo apt install raspi-gpio`
Second: install shutdown_fan script as descriped in point 6
Today (03/05/18) I got a NESPi+ case so I was able to elaborate the issue. Thanks to gollumer for your patince!

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

Here is my small contribution for some people out here. This script supports 
* NESPiCase (Shutdown-Mod by Yahmez)
* NESPi+ Case (Original from RetroFlag)
* GenericButton (multi purpose)
* MausBerry device (original script, modified for safe shutdown
* Pimoroni OnOff Shim (script modified by me)

All scripts support safe shutdown via power button and full detection of running emulators.
So you hopefully will never loose scraped images, favourites and last played ;)

I added system parameter commands now

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

The Switch Devices should be setup manually in the script itself.

Take a look to script code you will find blocks like
Now change the GPIO numbers as you did in your connection
Please don't exchange sorting order.....!

```
    --"NESPICASE")
       # NESPiCase with mod by Yahmez
       # https://retropie.org.uk/forum/topic/12424
       # Defaults are:
       # ResetSwitch GPIO 23, input, set pullup resistor!
       # PowerSwitch GPIO 24, input, set pullup resistor!
       # PowerOnControl GPIO 25, output, high
       # Enter other BCM connections to call
      NESPiCase 23 24 25
    ;;      
```

This script provides support for 3 devices now. More to come with help from others! So this bash script uses some function calls that may be usefull for extended usecases. 

# Todo:
* ~~We are missing dkpg-check for package~~ (done in v0.32)
* ~~sudo user check~~ (done in v0.32)
* config files
