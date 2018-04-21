# ES-generic-shutdown
A script that includes a few known standard power switches (MAUSBERRY, SHIM, POLOLU) and gots a default config for a safe shutdown.

## The [MultiSwitch - ShutdownScript](https://github.com/crcerror/ES-generic-shutdown/blob/master/multi_switch.sh)

To install:
1. Save the script to some place maybe `/home/pi/RetroPie/scripts/multi_switch.sh`
2. Make the script executable with `chmod +x /home/pi/RetroPie/scripts/multi_switch.sh`
3. Now edit ES autostart with `nano /opt/retropie/configs/all/autostart.sh` and add script to like ....
 4. `sudo /home/pi/RetroPie/scripts/multi_switch.sh &` but BEFORE the last line **emulationstatio #auto**
4.1 the **sudo** commands depends of usecase, Mausberry and OnOffShim needs it for GPIO export, NESPiCase not
4.2 NESPiCase @Yahmez -Mod makes use of internal PullUp Resistors, therefore `raspi-gpio` is needed
4.3 Install **raspi-gpio** with `sudo apt install raspi-gpio` (only for NESPiCase and Yahmez-Mod needed!)
 5. Give me some feedback ;)


Here is my small contribution for some people out here. This script supports 
* NESPiCase (hope Yahmez can test)
* MausBerry device (original script, modified for safe shutdown
* Pimoroni OnOff Shim (script modified by me)

All scripts support safe shutdown via power button and full detection of running emulators.
So you hopefully will never loose scraped images, favourites and last played ;)

Comment out lines that you don't need! Don't comment out second or more devices! This may cause issues!
The numbers displayed are each BCM pins, you can change them as you like but don't change order and use only one device.

* If you use the NESPiCase then comment out the line `NESPiCase 23 24 25`
* If you use the Mausberry circuit then comment out the line `Mausberry 23 24`
* If you use the Shim form Pimoroni then comment out the line `OnOffShim 17 4`

```
# NESPiCase with mod by Yahmez
# https://retropie.org.uk/forum/topic/12424
# Defaults are:
# ResetSwitch GPIO 23, input, set pullup resistor!
# PowerSwitch GPIO 24, input, set pullup resistor!
# PowerOnControl GPIO 25, output, high
# Enter other BCM connections to call

NESPiCase 23 24 25
```

This script provides support for 3 devices now. More to come with help from others! So this bash script uses some function calls that may be usefull for extended usecases. 

# Todo:
* We are missing dkpg-check for package
* sudo user check
* config files
