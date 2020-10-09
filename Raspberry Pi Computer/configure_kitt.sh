#!/bin/bash

rc="sudo raspi-config nonint"
ag="sudo apt-get -y"
null="/dev/null"
home="/home/pi"
homea="$home/Arduino"
homes="$home/sketchbook"
bconf="/boot/config.txt"
pvim="$home/.vimrc"
rvim="/root/.vimrc"
brc="$home/.bashrc"
autostart="/etc/xdg/lxsession/LXDE-pi/autostart"
libfmconf="/etc/xdg/libfm/libfm.conf"
lightdm="/etc/lightdm/lightdm.conf"
smbconf="/etc/samba/smb.conf"
smbuser=pi
ardpref="/home/pi/.arduino/preferences.txt"
rmpkgs="bluej geany* greenfoot* sagemath* wolfram-engine mu-* nodered scratch* sonic-pi* thonny sense-* smartsim* xboing code-the-classics minecraft-pi python-games claws*"
addpkgs="vim matchbox-keyboard gpsd gpsd-clients foxtrotgps navit* espeak subversion git locate samba samba-common-bin arduino* python-opencv" 
#### Other packages for consideration - kodi kodi-audioencoder-flac kodi-audioencoder-wav kodi-peripheral-joystick kodi-vfs-nfs kodi-vfs-rar kodi-vfs-sftp # mednafen

#### System updates, deprecated/undesired packages cleanup, & required packages install
$ag remove $rmpkgs && $ag update && $ag dist-upgrade && $ag install $addpkgs

#### raspi-config - non-boolean options
#$rc do_boot_behaviour B4
#$rc do_overclock None|Modest|Medium|High|Turbo
#$rc get_config_var hdmi_group $bconf
$rc do_hostname "kitt"
$rc do_memory_split 256
$rc do_wifi_country "US"
#### raspi-config - 1|0 -> 1=false/off 0=true/on
for on in do_boot_splash do_overscan do_camera do_ssh do_vnc do_spi do_i2c do_onewire do_rgpio; do $rc $on 0; done
for off in do_pixdub do_serial do_blanking; do $rc $off 1; done
#### config.txt - Ensure graphics start at boot
if [ "$(grep "start_x=1" $bconf)" = "" ]; then sudo sed -i '/^[all]/a start_x=1' $bconf; fi
#### config.txt - Add in configuration required for dual monitors with 800x480 display
if [ "$(grep "HDMI:1" $bconf)" = "" ]; then
	for i in 0 1; do
		echo -e "[HDMI:$i]\nhdmi_force_hotplug=1\nhdmi_group=2\nhdmi_mode=87\nhdmi_cvt 800 480 60 6 0 0 0\n" | sudo tee -a $bconf >> $null
	done
fi
#### Installing Python packages
if [ "$(pip3 list | grep opencv-python)" = "" ]; then
	pip3 install opencv-python
fi
#### vim preferences
if [ "$(grep mouse $pvim)" = "" ]; then echo "set mouse-=a" | sudo tee -a $rvim >> $pvim; fi
if [ "$(grep "syntax on" $pvim)" = "" ]; then echo "syntax on" | sudo tee -a $rvim >> $pvim; fi
if [ "$(grep "alias vi" $brc)" = "" ]; then sed -i '/alias ll/a alias vi=vim' $brc; fi
#### arduino preferences
if [ -f "$ardpref" ]; then
	if ![ "$(grep "height.default=480" $ardpref)" = "" ]; then
		sed -i 's/height.default=*/height.default=480/g' $ardpref
		sed -i 's/width.default=*/width.default=800/g' $ardpref
	fi
fi
for i in Robot_Control Robot_Motor Esplora Ethernet GSM Servo Wifi Stepper TFT; do
	if [ -d "/usr/share/arduino/libaries/$i" ]; then
		if ![ "/usr/share/arduino/libraries/$i" = "/usr/share/arduino/libraries/" ]; then
			cd /usr/share/arduino/libraries/
			rm -rf $i
		fi
	fi
done
#Install arduino-cli
if ![ -d "$homea" ]; then
	mkdir -p $homea/libraries
else
	cd $homea
	curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
	if [ -f "$homes/libraries" ]; then
		if [ -d "$homes/libraries" ]; then
			mv $homes/libraries/* $homea/libraries/
			rmdir $homes/libraries
		fi
		if ![ -L "$homes/libraries" ]; then
			ln -s $homea/libraries $homes/libraries
		fi
fi
#### Disable prompts on executing icons
if ![ "$(grep "quick_exec" $libfmconf)" = "" ]; then
	if [ "$(grep "quick_exec=1" $libfmconf)" = "" ]; then
		sudo sed -i 's/quick_exec=0/quick_exec=1/g' $libfmconf
	fi
else sudo sed -i '/^[config]/a quick_exec=1' $libfmconf
fi
#### Set up Samba file shares
if [ "$(grep "sketchbook" $smbconf)" = "" ]; then
	sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.original
	echo -e "[global]\n   workgroup = WORKGROUP\n   log file = /var/log/samba/log.%m\n   max log size = 1000\n   logging = file\n   panic action = /usr/share/samba/panic-action %d\n   server role = standalone server\n   obey pam restrictions = yes\n   unix password sync = yes\n   passwd program = /usr/bin/passwd %u\n   passwd chat = *Enter\\snew\\s*\\spassword:* %n\\\n *Retype\\snew\\s*\\spassword:* %n\\\n *password\\supdated\\ssuccessfully* .\n   pam password change = yes\n   map to guest = bad user\n   usershare allow guests = no" | sudo tee $smbconf >> $null
	# Create shares for each of these directories
	for dir in Videos Maps sketchbook scripts; do
	  if ![ -d "$home/$dir" ]; then
		mkdir -p $home/$dir
	  fi
	  echo -e "[$dir]\n   comment = $dir\n   path = $home/$dir\n   guest ok = no\n   read only = no\n   create mask = 0700\n   directory mask = 0700\n   valid user = $smbuser" | sudo tee -a $smbconf >> $null
	done
	#### If smb user doesn't exist, create it
	if [ "$(sudo pdbedit -L | grep $smbuser)" = "" ]; then smbpasswd -a $smbuser; fi
fi
# Add in script that ensures touch screens are properly mapped
if ![ -f "$home/scripts/align_touch.sh" ]; then
	echo -e "#!/bin/bash\n# xinput - displays pointers/keyboards\n# xrandr - shows screen names\ninput1=\$(xinput | grep wch.cn | head -1 | cut -f2 | cut -d'=' -f2)\ninput2=\$(xinput | grep wch.cn | tail -1 | cut -f2 | cut -d'=' -f2)\nscreen1=\$(xrandr | grep connected | head -1 | cut -f1)\nscreen2=\$(xrandr | grep connected | tail -1 | cut -f1)\nxinput map-to-output \$input1 \$screen1\nxinput map-to-output \$input2 \$screen2\n#static commands\n#xinput map-to-output 9 HDMI-1\n#xinput map-to-output 10 HDMI-2" | sudo tee $home/scripts/align_touch.sh >> $null
fi
#### Ensure align_touch.sh runs at user login
if [ "$(grep "align_touch" $autostart)" = "" ]; then
	echo "@lxterminal -e bash $home/scripts/align_touch.sh" | sudo tee -a $autostart >> $null
fi
#### Disable screen blanking
if [ "$(grep "xserver-command=X -s 0 -dpms" $lightdm)" = "" ]; then
	sudo sed -i 's/^#xserver-command=X/xserver-command=X -s 0 -dpms/g' $lightdm
fi
