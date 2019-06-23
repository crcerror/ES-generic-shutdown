# Automatik install of multi_switch.sh script
# Thanks to @neo954 for some script code

# Check for SU/ROOT
[[ $USER != "root" ]] && echo "Need root privileges... just run with 'sudo $0'" && exit

# Install package raspi-gpio
apt-get install -y raspi-gpio

# Create Directories and download scripts
mkdir -p /home/pi/RetroPie/scripts
cd /home/pi/RetroPie/scripts
wget -N -q --show-progress https://raw.githubusercontent.com/crcerror/ES-generic-shutdown/master/multi_switch.sh

# Set user rights
chmod +x multi_switch.sh
chown -R pi:pi ../scripts

# Create auto startup
sed -i -e '/\/home\/pi\/RetroPie\/scripts\/multi_switch.sh/ d' -e '1i /home/pi/RetroPie/scripts/multi_switch.sh --nespi+ &' /opt/retropie/configs/all/autostart.sh

# This is shutdown script, it seems to be used in some bare cases
#cd /lib/systemd/system-shutdown
#wget -N -q --show-progress https://raw.githubusercontent.com/crcerror/ES-generic-shutdown/master/shutdown_fan
#chmod +x shutdown_fan
