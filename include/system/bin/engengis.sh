#!/system/bin/sh
# Copyright (c) 2012 - redmaner 
# Engengis project

# Version information
BUILD=51
VERSION=v0.5.5.3
CODENAME=Delta
AUTHOR=Redmaner
STATUS=Stable
OFFICIAL=Yes

# Engengis information
LOG=/data/engengis.log
CONFIG=/data/engengis.conf
SETTINGS=/data/settings.conf
SYSTEMTWEAK=/system/etc/init.d/S00systemtweak
HSSTWEAK=/system/etc/init.d/S07hsstweak
ZIPALIGN=/system/etc/init.d/S14zipalign
INTSPEED=/system/etc/init.d/S56internet
INTSECURE=/system/etc/init.d/S63internetsecurity
DROPCACHES=/system/etc/init.d/S49dropcaches
SCHEDULER=/system/etc/init.d/S28scheduler
READSPEED=/system/etc/init.d/S35sdreadspeed
CPUGTWEAK=/system/etc/init.d/S21governortweak
GOVERNOR=/system/etc/init.d/S42cpugovernor
BPROP=/system/build.prop
TEMP=/cache/engengis.tmp


# -------------------------------------------------------------------------
# Check requirements to run engengis
# -------------------------------------------------------------------------
check () {
clear
mount -o remount,rw /system

if [ -e /sdcard/updater.sh ]; then
    rm -f /sdcard/updater.sh
fi;

if [ -e $LOG ]; then
    rm -f $LOG
fi;

touch $LOG
echo "Engengis started at `date`" >> $LOG

if [ -e /system/xbin/su ]; then
    echo "Root = Ok" >> $LOG;
    echo "SU binary detected: /system/xbin/su" >> $LOG;
elif [ -e /system/bin/su ]; then
    echo "Root = Ok" >> $LOG;
    echo "SU binary detected: /system/bin/su" >> $LOG;
else
    echo "Root = failure" >> $LOG;
    echo "SU binary not detected" >> $LOG;
    echo "SU binary has not been found!"
    echo "Please be sure you are rooted"
    exit
fi;

if [ -e /system/xbin/busybox ]; then
    echo "Busybox = Ok" >> $LOG;
    echo "Busybox detected: /system/xbin/busybox" >> $LOG;
elif [ -e /system/bin/busybox ]; then
    echo "Busybox = Ok" >> $LOG;
    echo "Busybox detected: /system/bin/busybox" >> $LOG;
else
    echo "Busybox = failure" >> $LOG;
    echo "Busybox binary not detected" >> $LOG;
    echo "Busybox binary has not been found!"
    echo "Please be sure you have busybox installed"
    exit
fi;

if [ -d /system/etc/init.d ]; then
    echo "init.d folder = Ok" >> $LOG;
else
    mkdir /system/etc/init.d
    echo "Created init.d folder" >> $LOG;
    echo "Created init.d folder"
    sleep 1
fi;

if [ -e $CONFIG ]; then
    echo "Configuration file = Ok" >> $LOG;
else
    touch $CONFIG;
    sleep 1
    echo "otasupport=off" >> $CONFIG;
    echo "status=firstboot" >> $CONFIG;
    echo "automaticrestore=on" >> $CONFIG;
    echo "passwordprotection=off" >> $CONFIG;
    echo "Configuration file created" >> $LOG;
    echo "Created configuration file";
    sleep 1
fi;

if [ -e $SETTINGS ]; then
    echo "Settings file = Ok" >> $LOG;
else
    touch $SETTINGS
    echo "zipalignduringboot=off" >> $SETTINGS;
    echo "dropcachesduringboot=off" >> $SETTINGS;
    echo "internetspeed=off" >> $SETTINGS;
    echo "ioscheduler=default" >> $SETTINGS;
    echo "sdreadspeed=default" >> $SETTINGS;
    echo "governortweak=off" >> $SETTINGS;
    echo "Settings file created" >> $LOG;
    echo "Settings file created"
    sleep 1
fi;

clear
if [ $(cat $CONFIG | grep "disclaimer=accepted" | wc -l) -gt 0 ]; then
     echo "Disclaimer = Ok" >> $LOG;
else
     echo "------------------------"
     echo "Engengis.Disclaimer     "
     echo "------------------------"
     echo
     echo "** Use at your own risk!"
     echo
     echo "** If engengis bricks your phone or your girlfriend breaks up with you"
     echo
     echo "** then don't point at us, we'll laugh at you!"
     echo
     echo "** You decided to use engengis so it's your responsibility!"
     echo
     echo "Do you accept the disclaimer?"
     echo "[y/n]"
     read disclaimer
fi;

case "$disclaimer" in
  "y" | "Y")
  sed -i '/disclaimer=*/ d' $CONFIG;
  echo "disclaimer=accepted" >> $CONFIG;;
  "n" | "N")
  clear
  exit
  ;;
esac
}

if [ $(cat $CONFIG | grep "version=charlie" | wc -l) -gt 0 ]; then
     sed -i '/systemtweak=*/ d' $SETTINGS;
     sed -i '/internettweaks=*/ d' $SETTINGS;
     sed -i '/lmk=*/ d' $SETTINGS;
     sed -i '/cpugovernor=*/ d' $SETTINGS;
     echo "Cleaned up settings file..."
     echo "Cleaned up settings file" >> $LOG
     sleep 1 
fi;

if [ $(cat $CONFIG | grep "version=delta" | wc -l) -gt 0 ]; then
    echo "Engengis.Delta detected" >> $LOG;
else
    sed -i '/version=*/ d' $CONFIG;
    echo "version=delta" >> $CONFIG;
fi;

user () {
clear
if [ $(cat $CONFIG | grep "user=normal" | wc -l) -gt 0 ]; then
     echo "Normal user detected" >> $LOG
elif [ $(cat $CONFIG | grep "user=advanced" | wc -l) -gt 0 ]; then
     echo "Advanced user detected >> $LOG"
else
     echo "What for kind off user are you?"
     echo
     echo " 1 - Normal user (recommended)"
     echo " 2 - Advanced user"
     echo
     echo -n "Please enter your option: "; read user_option;
fi;

case "$user_option" in
  "1")
  sed -i '/user=*/ d' $CONFIG;
  echo "user=normal" >> $CONFIG;;
  "2")
  sed -i '/user=*/ d' $CONFIG;
  echo "user=advanced" >> $CONFIG;;
esac
}

# -------------------------------------------------------------------------
# Check resource files
# -------------------------------------------------------------------------
if [ -e /system/lib/libncurses.so ]; then
    echo "libncurses.so detected" >> $LOG
else
    cp /system/etc/engengis/resources/libncurses.so /system/lib/libncurses.so
    chmod 775 /system/lib/libncurses.so
    echo "Loaded libncurses.so"
    echo "Loaded libncurses.so" >> $LOG
fi;

if [ -e /system/xbin/sqlite3 ]; then
    echo "sqlite3 binary detected" >> $LOG
else
    cp /system/etc/engengis/resources/sqlite3 /system/xbin/sqlite3
    chmod 775 /system/xbin/sqlite3
    echo "Loaded sqlite3 binary"
    echo "Loaded sqlite3 binary" >> $LOG
fi;

if [ -e /system/xbin/zipalign ]; then
    echo "zipalign binary detected" >> $LOG
else
    cp /system/etc/engengis/resources/zipalign /system/xbin/zipalign
    chmod 775 /system/xbin/zipalign
    echo "Loaded zipalign binary"
    echo "Loaded zipalign binary" >> $LOG
fi;

# ------------------------------------------------------------------------
# Check password/user --> Option in engengis settings
# ------------------------------------------------------------------------
check_password () {
if [ $(cat $CONFIG | grep "passwordprotection=on" | wc -l) -gt 0 ]; then
     password_procedure;
else
     check_restore;
fi;
}

password_procedure () {
clear
if [ -d /data/engengis-user ]; then
     echo "Welcome back: `cat /data/engengis-user/name.txt`"
     echo -n "Password: "; read password_input;
     if [ $password_input = "`cat /data/engengis-user/password.txt`" ]; then
           echo "Password = correct"; sleep 1; check_restore;
     else
           echo "Password = Wrong"; sleep 1; password_procedure;
     fi;
else
     user_setup;
fi;
}

user_setup () {
clear
rm -rf /data/engengis-user
mkdir -p /data/engengis-user
echo -n "Please enter your name: "; read username_input_setup;
echo "$username_input_setup" > /data/engengis-user/name.txt
password_setup;
}

password_setup () {
echo -n "Please enter a password: "; read password_input_setup;
echo "$password_input_setup" > /data/engengis-user/password.txt
echo -n "Please confirm password: "; read password_confirm_setup;
if [ $password_confirm_setup = $password_input_setup ]; then
     echo
     echo "User profile setup complete!"; sleep 2;
     check_password;
else
     echo
     echo "Password doesn't match first input"
     password_setup;
fi;
}       

# -------------------------------------------------------------------------
# Check status of engengis
# -------------------------------------------------------------------------
check_restore () {
if [ $(cat $CONFIG | grep "automaticrestore=on" | wc -l) -gt 0 ]; then
     firstboot;
else
     entry;
fi;
}

firstboot () {
clear
if [ $(cat $CONFIG | grep "status=firstboot" | wc -l) -gt 0 ]; then
     rm -f /data/updated
     echo "Engengis running for the fist time" >> $LOG
     echo "You are using Engengis for the first time!"
     echo "To help you out we selected a few tweaks for you"
     echo "Those tweaks are:"
     echo
     echo "- Zipalign during boot"
     echo "- Dropcaches during boot"
     echo "- SD readspeed 256kb"
     echo "- Internet speed tweaks"
     echo 
     echo "Do you want to enable them?"
     echo "[y/n]"
     read firstboot
else
     updated;
fi;

case "$firstboot" in
  "y" | "Y")
  cp /system/etc/engengis/S14zipalign $ZIPALIGN;
  chmod 777 $ZIPALIGN;
  sed -i '/zipalignduringboot=*/ d' $SETTINGS;
  echo "zipalignduringboot=on" >> $SETTINGS;
  cp /system/etc/engengis/S49dropcaches $DROPCACHES;
  chmod 777 $DROPCACHES;
  sed -i '/dropcachesduringboot=*/ d' $SETTINGS;
  echo "dropcachesduringboot=on" >> $SETTINGS;
  cp /system/etc/engengis/S35sd256 $READSPEED;
  chmod 777 $READSPEED;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=256" >> $SETTINGS;
  cp /system/etc/engengis/S56internet $INTSPEED;
  chmod 777 $INTSPEED;
  sed -i '/internetspeed=*/ d' $SETTINGS;
  echo "internetspeed=on" >> $SETTINGS;
  clear
  echo "Recommended tweaks are now ENABLED"
  sleep 2
  sed -i '/status=*/ d' $CONFIG;
  echo "status=normal" >> $CONFIG;
  systemtweak_option;;
  "n" | "N")
  clear
  sed -i '/status=*/ d' $CONFIG;
  echo "status=normal" >> $CONFIG;
  systemtweak_option;;
esac
}

updated () {
clear
if [ $(cat $CONFIG | grep "status=updated" | wc -l) -gt 0 ]; then
     rm -f /data/updated
     echo "Engengis has been updated" >> $LOG
     echo "Engengis has been updated!"
     echo "Your settings are removed!"
     echo "Saved the following settings:"
     echo
     cat $SETTINGS
     echo
     echo "Do you want to restore them?"
     echo "[y/n]"
     read restore_settings;
fi;

if [ -e /data/updated ]; then
     rm -f /data/updated
     echo "Engengis has been updated" >> $LOG
     echo "Engengis has been updated!"
     echo "Your settings are removed!"
     echo "Saved the following settings:"
     echo
     cat $SETTINGS
     echo
     echo "Do you want to restore them?"
     echo "[y/n]"
     read restore_settings;
else
    echo "Engengis running fine" >> $LOG
fi;
 
case "$restore_settings" in
  "y" | "Y")
  if [ $(cat $SETTINGS | grep "zipalignduringboot=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S14zipalign $ZIPALIGN;
       chmod 777 $ZIPALIGN;
  fi;
  if [ $(cat $SETTINGS | grep "dropcachesduringboot=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S49dropcaches $DROPCACHES;
       chmod 777 $DROPCACHES;
  fi;
  if [ $(cat $SETTINGS | grep "internetspeed=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S56internet $INTSPEED;
       chmod 777 $INTSPEED;
  fi;
  if [ $(cat $SETTINGS | grep "internetsecurity=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S63internetsecurity $INTSECURE;
       chmod 777 $INTSECURE;
  fi;
  if [ $(cat $SETTINGS | grep "governortweak=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S21governortweak $CPUGTWEAK;
       chmod 777 $CPUGTWEAK;
  fi;
  if [ $(cat $SETTINGS | grep "ioscheduler=bfq" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S28bfqscheduler $SCHEDULER;
       chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=cfq" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28cfqscheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=deadline" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28deadlinescheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=noop" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28noopscheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=vr" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28vrscheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=sio" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28sioscheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  fi;
  if [ $(cat $SETTINGS | grep "sdreadspeed=256" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S35sd256 $READSPEED;
       chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=512" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd512 $READSPEED;
         chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=1024" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd1024 $READSPEED;
         chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=2048" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd2048 $READSPEED;
         chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=3072" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd3072 $READSPEED;
         chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=4096" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd4096 $READSPEED;
         chmod 777 $READSPEED;
  fi;
  clear
  echo "Restored old settings!"
  sleep 1
  sed -i '/status=*/ d' $CONFIG;
  echo "status=normal" >> $CONFIG;
  sleep 1
  systemtweak_option;;
  "n" | "N")
  clear
  rm -f $SETTINGS
  touch $SETTINGS
  echo "zipalignduringboot=off" >> $SETTINGS;
  echo "dropcachesduringboot=off" >> $SETTINGS;
  echo "internetspeed=off" >> $SETTINGS;
  echo "ioscheduler=default" >> $SETTINGS;
  echo "sdreadspeed=default" >> $SETTINGS;
  echo "governortweak=off" >> $SETTINGS;
  sed -i '/status=*/ d' $CONFIG;
  echo "status=normal" >> $CONFIG;
  systemtweak_option;;
esac
}

systemtweak_option () {
clear
echo "Do you want to set your systemtweak now?"
echo "[y/n]"
read optionram
case "$optionram" in
  "y" | "Y") echo "entry" > $TEMP; systemtweak_config;;
  "n" | "N") entry;;
esac
}


# -------------------------------------------------------------------------
# Engengis main menu
# -------------------------------------------------------------------------
entry () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - System tweaks" 
echo " 2 - I/O scheduler settings" 
echo " 3 - SD-Readspeed settings"
echo " 4 - CPU governor settings"
echo " 5 - Disply resolution (dpi)"
echo " 6 - Build.prop optimizations"
echo " 7 - Engengis settings"
echo " 8 - Script manager"
echo
if [ -e /system/bin/terminal ]; then
    echo " t - Start terminal"
fi;
if [ $(cat $CONFIG | grep "otasupport=on" | wc -l) -gt 0 ]; then
    echo " u - Check for updates" 
fi;
echo " r - Reboot (apply changes)"
echo " e - Exit"
echo
echo -n "Please enter your choice: "; read option;
case "$option" in
  "1") systemtweaksmenu;;
  "2") schedulermenu;;
  "3") readspeedmenu;;
  "4") governormenu;;
  "5") dpimenu;;
  "6") buildpropmenu;;
  "7") settingsmenu;;
  "8") script_manager;;
  "t" | "T") 
  if [ -e /system/bin/terminal ]; then
       terminal;
  elif [ -e /system/etc/engengis/terminal ]; then
       echo
       echo "Engengis terminal is disabled"
       echo "Do you want to enable it now?"
       echo "[y/n]"
       read engengisterminal
  else
       echo
       echo "Terminal is not supported by your build"
       sleep 2
       entry;
  fi;;
  "u" | "U")
  if [ $(cat $CONFIG | grep "otasupport=on" | wc -l) -gt 0 ]; then
      clear
      echo "Starting updater, please wait..."
      wget -q http://dl.dropbox.com/u/26139869/engengis/updater.sh -O /sdcard/updater.sh
      chmod 777 /sdcard/updater.sh
      sh /sdcard/updater.sh
  else
      entry;
  fi;;
  "check") clear; check; user; check_password; entry;;
  "force") sh /system/etc/init.d/*; entry;;
  "r" | "R") reboot ;;
  "e" | "E") clear; exit ;;
esac

case "$engengisterminal" in
  "y" | "Y")
  cp /system/etc/engengis/terminal /system/bin/terminal
  chmod 777 /system/bin/terminal
  echo 
  echo "Terminal enabled"
  sleep 2
  entry;;
  "n" | "N") entry;;
esac
}

# -------------------------------------------------------------------------
# Engengis systemtweaks menu
# -------------------------------------------------------------------------
systemtweaksmenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Configure systemtweak" 
if [ -e $ZIPALIGN ]; then
      echo " 2 - Disable zipalign during boot" 
else
      echo " 2 - Enable zipalign during boot" 
fi;
echo " 3 - Optimize sqlite db's"
if [ -e $DROPCACHES ]; then
      echo " 4 - Disable drop caches during boot" 
else
      echo " 4 - Enable drop caches during boot" 
fi;
if [ -e $INTSPEED ]; then
      echo " 5 - Disable internet speed tweaks" 
else
      echo " 5 - Enable internet speed tweaks" 
fi;
if [ -e $INTSECURE ]; then
      echo " 6 - Disable internet security tweaks" 
else
      echo " 6 - Enable internet security tweaks" 
fi;
echo " b - Back"
echo
echo -n "Please enter your choice: "; read tweaks;
case "$tweaks" in
  "1") echo "systemtweaksmenu" > $TEMP; systemtweak_config;;
  "2")
  if [ -e $ZIPALIGN ]; then
        rm -f $ZIPALIGN;
        rm -f /data/zipalign.db;
        rm -f /data/zipalign.log;
        sed -i '/zipalignduringboot=*/ d' $SETTINGS;
        echo "zipalignduringboot=off" >> $SETTINGS;
        sleep 2
        systemtweaksmenu;
  else
        cp /system/etc/engengis/S14zipalign $ZIPALIGN;
        chmod 777 /system/xbin/zipalign;
        chmod 777 $ZIPALIGN;
        sed -i '/zipalignduringboot=*/ d' $SETTINGS;
        echo "zipalignduringboot=on" >> $SETTINGS;
        sleep 2
        systemtweaksmenu;
  fi;;
  "3")
  clear
  echo "Ignore all errors during proces!"
  echo "Errors won't harm your phone!"
  sleep 3
  clear
  echo "Optimizing Sqlite db's please wait..."
  sleep 1
  # Thanks to pikachu01 for this script.
  # All credits for this script goes to him.
	for i in \
	`busybox find /data -iname "*.db"`; 
	do \
		/system/xbin/sqlite3 $i 'VACUUM;'; 
		/system/xbin/sqlite3 $i 'REINDEX;'; 
	done;
	if [ -d "/dbdata" ]; then
		for i in \
		`busybox find /dbdata -iname "*.db"`; 
		do \
			/system/xbin/sqlite3 $i 'VACUUM;'; 
			/system/xbin/sqlite3 $i 'REINDEX;'; 
		done;
	fi;
	if [ -d "/datadata" ]; then
		for i in \
		`busybox find /datadata -iname "*.db"`; 
		do \
			/system/xbin/sqlite3 $i 'VACUUM;'; 
			/system/xbin/sqlite3 $i 'REINDEX;'; 
		done;
	fi;
	for i in \
	`busybox find /sdcard -iname "*.db"`; 
	do \
		/system/xbin/sqlite3 $i 'VACUUM;'; 
		/system/xbin/sqlite3 $i 'REINDEX;'; 
	done;
  systemtweaksmenu;;
  "4")
  if [ -e $DROPCACHES ]; then 
        rm -f $DROPCACHES;
        sed -i '/dropcachesduringboot=*/ d' $SETTINGS;
        echo "dropcachesduringboot=off" >> $SETTINGS;
        sleep 2
        systemtweaksmenu;
  else
        cp /system/etc/engengis/S49dropcaches $DROPCACHES;
        chmod 777 $DROPCACHES;
        sed -i '/dropcachesduringboot=*/ d' $SETTINGS;
        echo "dropcachesduringboot=on" >> $SETTINGS;
        sleep 2
        systemtweaksmenu;
  fi;;
  "5")
  if [ -e $INTSPEED ]; then 
        rm -f $INTSPEED;
        sed -i '/internetspeed=*/ d' $SETTINGS;
        echo "internetspeed=off" >> $SETTINGS;
        sleep 2
        systemtweaksmenu;
  else
        cp /system/etc/engengis/S56internet $INTSPEED;
        chmod 777 $INTSPEED;
        sed -i '/internetspeed=*/ d' $SETTINGS;
        echo "internetspeed=on" >> $SETTINGS;
        sleep 2
        systemtweaksmenu;
  fi;;
  "6")
  if [ -e $INTSECURE ]; then 
        rm -f $INTSECURE;
        sed -i '/internetsecurity=*/ d' $SETTINGS;
        echo "internetsecurity=off" >> $SETTINGS;
        sleep 2
        systemtweaksmenu;
  else
        cp /system/etc/engengis/S63internetsecurity $INTSECURE;
        chmod 777 $INTSECURE;
        sed -i '/internetsecurity=*/ d' $SETTINGS;
        echo "internetsecurity=on" >> $SETTINGS;
        sleep 2
        systemtweaksmenu;
  fi;;
  "b" | "B") entry;;
  "r" | "R") reboot ;;
esac
}

# -------------------------------------------------------------------------
# Engengis IO scheduler menu
# -------------------------------------------------------------------------
schedulermenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Set BFQ scheduler"
echo " 2 - Set CFQ scheduler"
echo " 3 - Set Deadline scheduler"
echo " 4 - Set Noop scheduler"
echo " 5 - set VR scheduler"
echo " 6 - set Simple scheduler"
echo " 7 - Check I/O scheduler support"
if [ -e $SCHEDULER ]; then
     echo " 8 - Remove scheduler settings"
fi;
echo " b - Back"
if [ -e $SCHEDULER ]; then
     echo
     echo "------------------------"
     cat $SCHEDULER | grep "Scheduler = *"
fi;
echo
echo -n "Please enter your choice: "; read options;

case "$options" in
  "1")
  cp /system/etc/engengis/S28bfqscheduler $SCHEDULER;
  chmod 777 $SCHEDULER;
  sed -i '/ioscheduler=*/ d' $SETTINGS;
  echo "ioscheduler=bfq" >> $SETTINGS;
  schedulermenu;;
  "2")
  cp /system/etc/engengis/S28cfqscheduler $SCHEDULER;
  chmod 777 $SCHEDULER;
  sed -i '/ioscheduler=*/ d' $SETTINGS;
  echo "ioscheduler=cfq" >> $SETTINGS;
  schedulermenu;;
  "3")
  cp /system/etc/engengis/S28deadlinescheduler $SCHEDULER;
  chmod 777 $SCHEDULER;
  sed -i '/ioscheduler=*/ d' $SETTINGS;
  echo "ioscheduler=deadline" >> $SETTINGS;
  schedulermenu;;
  "4")
  cp /system/etc/engengis/S28noopscheduler $SCHEDULER;
  chmod 777 $SCHEDULER;
  sed -i '/ioscheduler=*/ d' $SETTINGS;
  echo "ioscheduler=noop" >> $SETTINGS;
  schedulermenu;;
  "5")
  cp /system/etc/engengis/S28vrscheduler $SCHEDULER;
  chmod 777 $SCHEDULER;
  sed -i '/ioscheduler=*/ d' $SETTINGS;
  echo "ioscheduler=vr" >> $SETTINGS;
  schedulermenu;;
  "6")
  cp /system/etc/engengis/S28sioscheduler $SCHEDULER;
  chmod 777 $SCHEDULER;
  sed -i '/ioscheduler=*/ d' $SETTINGS;
  echo "ioscheduler=sio" >> $SETTINGS;
  schedulermenu;;
  "7")
  BML=`ls -d /sys/block/bml*`;
  MMC=`ls -d /sys/block/mmc*`;
  MTD=`ls -d /sys/block/mtd*`;
  STL=`ls -d /sys/block/stl*`;
  TFSR=`ls -d /sys/block/tfsr*`;
  ZRAM=`ls -d /sys/block/zram*`;
  clear
  for i in $BML $MMC $MTD $STL $TFSR $ZRAM;  do
      cat $i/queue/scheduler
  done;
  sleep 7
  schedulermenu;;
  "8")
  if [ -e $SCHEDULER ]; then
        rm -f $SCHEDULER
  fi;
  sed -i '/ioscheduler=*/ d' $SETTINGS;
  echo "ioscheduler=default" >> $SETTINGS;
  schedulermenu;;
  "b" | "B") entry;;
  "r" | "R") reboot ;;
esac
}

# -------------------------------------------------------------------------
# Engengis SD-readspeed menu
# -------------------------------------------------------------------------
readspeedmenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Set SD-Readspeed to 256kb"
echo " 2 - Set SD-Readspeed to 512kb"
echo " 3 - Set SD-Readspeed to 1024kb"
echo " 4 - Set SD-Readspeed to 2048kb"
echo " 5 - Set SD-Readspeed to 3072kb"
echo " 6 - Set SD-Readspeed to 4096kb"
if [ -e $READSPEED ]; then
     echo " 7 - Remove SD-Readspeed settings"
fi;
echo " b - Back"
if [ -e $READSPEED ]; then
     echo
     echo "------------------------"
     cat $READSPEED | grep "SD-Readspeed = *"
fi;
echo
echo -n "Please enter your choice: "; read optionr;

case "$optionr" in
  "1")
  cp /system/etc/engengis/S35sd256 $READSPEED;
  chmod 777 $READSPEED;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=256" >> $SETTINGS;
  readspeedmenu;;
  "2")
  cp /system/etc/engengis/S35sd512 $READSPEED;
  chmod 777 $READSPEED;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=512" >> $SETTINGS;
  readspeedmenu;;
  "3")
  cp /system/etc/engengis/S35sd1024 $READSPEED;
  chmod 777 $READSPEED;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=1024" >> $SETTINGS;
  readspeedmenu;;
  "4")
  cp /system/etc/engengis/S35sd2048 $READSPEED;
  chmod 777 $READSPEED;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=2048" >> $SETTINGS;
  readspeedmenu;;
  "5")
  cp /system/etc/engengis/S35sd3072 $READSPEED;
  chmod 777 $READSPEED;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=3072" >> $SETTINGS;
  readspeedmenu;;
  "6")
  cp /system/etc/engengis/S35sd4096 $READSPEED;
  chmod 777 $READSPEED;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=4096" >> $SETTINGS;
  readspeedmenu;;
  "7")
  if [ -e $READSPEED ]; then
        rm -f $READSPEED
  fi;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=default" >> $SETTINGS;
  readspeedmenu;;
  "b" | "B") entry;;
  "r" | "R") reboot ;;
esac
}

# -------------------------------------------------------------------------
# Engengis CPU governor settings menu
# -------------------------------------------------------------------------
governormenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
if [ -e $CPUGTWEAK ]; then
     echo " 1 - Disable governortweak"
else
     echo " 1 - Enable governortweak"
fi;
echo " 2 - Set governor"
if [ -e $GOVERNOR ]; then
     echo " 3 - Remove governor settings"
fi;
echo " b - Back"
if [ -e $GOVERNOR ]; then
     echo
     echo "------------------------"
     cat $GOVERNOR | grep "CPUgovernor = * "
fi;
echo
echo -n "Please enter your choice: "; read optiong;

case "$optiong" in
  "1")
  if [ -e $CPUGTWEAK ]; then 
        rm -f $CPUGTWEAK;
        sed -i '/governortweak=*/ d' $SETTINGS;
        echo "governortweak=off" >> $SETTINGS;
        sleep 2
        governormenu;
  else
        cp /system/etc/engengis/S21governortweak $CPUGTWEAK;
        chmod 777 $CPUGTWEAK;
        sed -i '/governortweak=*/ d' $SETTINGS;
        echo "governortweak=on" >> $SETTINGS;
        sleep 2
        governormenu;
  fi;;
  "2") 
  if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
       setgovernor_cpu0;
  elif [ -e /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor ]; then
       setgovernor_cpu1;
  elif [ -e /sys/devices/system/cpu/cpufreq/scaling_governor ]; then
       setgovernor_cpufreq;
  else
       echo "Your device is not supported to change cpu governor"
  fi;;
  "3")
  if [ -e $GOVERNOR ]; then
       rm -f $GOVERNOR
  fi;
  governormenu;;
  "b" | "B") entry;;
  "r" | "R") reboot;;
esac
}

setgovernor_cpu0 () {
clear
echo
echo "Current governor: `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`" 
echo "Governors supported by kernel:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
echo
echo "Please type your governor you want to set (b for Back): ";
read governorinput;

if [ $governorinput = "b" ]; then
     governormenu;
fi;
if [ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | grep "$governorinput" | wc -l) -gt 0 ]; then
     cat > $GOVERNOR << EOF
#!/system/bin/sh
# Copyright (c) 2012, redmaner

# CPUgovernor = $governorinput
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo "$governorinput" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
fi
EOF
     chmod 777 $GOVERNOR
     rm -f $SCREENSTATE;
     sed -i '/screenstatescaling=*/ d' $SETTINGS;
     echo "screenstatescaling=off" >> $SETTINGS;
     echo
     echo "Governor set to: $governorinput"
     governormenu;
else
     echo "Kernel doesn't support $governorinput governor"
     sleep 2
     setgovernor;
fi;
}

setgovernor_cpu1 () {
clear
echo
echo "Current governor: `cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor`" 
echo "Governors supported by kernel:"
cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_available_governors
echo
echo "Please type your governor you want to set (b for Back): ";
read governorinput;

if [ $governorinput = "b" ]; then
     governormenu;
fi;
if [ $(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_available_governors | grep "$governorinput" | wc -l) -gt 0 ]; then
     cat > $GOVERNOR << EOF
#!/system/bin/sh
# Copyright (c) 2012, redmaner

# CPUgovernor = $governorinput
if [ -e /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor ]; then
        echo "$governorinput" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
fi
EOF
     chmod 777 $GOVERNOR
     rm -f $SCREENSTATE;
     sed -i '/screenstatescaling=*/ d' $SETTINGS;
     echo "screenstatescaling=off" >> $SETTINGS;
     echo
     echo "Governor set to: $governorinput"
     governormenu;
else
     echo "Kernel doesn't support $governorinput governor"
     sleep 2
     setgovernor;
fi;
}

setgovernor_cpufreq () {
clear
echo
echo "Current governor: `cat /sys/devices/system/cpu/cpufreq/scaling_governor`" 
echo "Governors supported by kernel:"
cat /sys/devices/system/cpu/cpufreq/scaling_available_governors
echo
echo "Please type your governor you want to set (b for Back): ";
read governorinput;

if [ $governorinput = "b" ]; then
     governormenu;
fi;
if [ $(cat /sys/devices/system/cpu/cpufreq/scaling_available_governors | grep "$governorinput" | wc -l) -gt 0 ]; then
     cat > $GOVERNOR << EOF
#!/system/bin/sh
# Copyright (c) 2012, redmaner

# CPUgovernor = $governorinput
if [ -e /sys/devices/system/cpu/cpufreq/scaling_governor ]; then
        echo "$governorinput" > /sys/devices/system/cpu/cpufreq/scaling_governor
fi
EOF
     chmod 777 $GOVERNOR
     rm -f $SCREENSTATE;
     sed -i '/screenstatescaling=*/ d' $SETTINGS;
     echo "screenstatescaling=off" >> $SETTINGS;
     echo
     echo "Governor set to: $governorinput"
     governormenu;
else
     echo "Kernel doesn't support $governorinput governor"
     sleep 2
     setgovernor;
fi;
}

# -------------------------------------------------------------------------
# Engengis DPI menu
# -------------------------------------------------------------------------
dpimenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo "Current:`cat $BPROP | grep "ro.sf.lcd_density=*"`"
echo
echo "Please enter your dpi value (b for Back): "; read dpiinput
echo
if [ $dpiinput = "b" ]; then
     entry;
fi;
echo "Your dpi value will be set to: $dpiinput"
echo "Are you sure?"
echo "[y/n]"
read dpioption
case "$dpioption" in
  "y" | "Y")
  sed -i '/ro.sf.lcd_density=*/ d' $BPROP;
  echo "ro.sf.lcd_density=$dpiinput" >> $BPROP;
  echo
  echo "Set dpi to $dpiinput"
  echo "Phone will reboot in a few seconds!"
  sleep 3
  reboot;;
  "n" | "N") dpimenu;;
esac
}

# -------------------------------------------------------------------------
# Engengis build.prop optimizations menu
# -------------------------------------------------------------------------
buildpropmenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
if [ $(cat $BPROP | grep "debug.sf.hw=0" | wc -l) -gt 0 ]; then
     echo " 1 - Enable UI rendering with GPU"
else
     echo " 1 - Disable UI rendering with GPU"
fi;
if [ $(cat $BPROP | grep "ro.media.enc.jpeg.quality=100" | wc -l) -gt 0 ]; then
     echo " 2 - Raise jpeg quality to 100% = applied"
else
     echo " 2 - Raise jpeg quality to 100%"
fi;
if [ $(cat $BPROP | grep "wifi.supplicant_scan_interval=60" | wc -l) -gt 0 ]; then
     echo " 3 - Set wifi interval to 60 = applied"
else 
     echo " 3 - Set wifi interval to 60"
fi;
if [ $(cat $BPROP | grep "ro.HOME_APP_ADJ=1" | wc -l) -gt 0 ]; then
     echo " 4 - Force launcher in memory = applied"
else
     echo " 4 - Force launcher in memory"
fi;
if [ $(cat $BPROP | grep "ro.telephony.call_ring.delay=0" | wc -l) -gt 0 ]; then
     echo " 5 - Decrease dialing out delay = applied"
else
     echo " 5 - Decrease dialing out delay"
fi;
if [ $(cat $BPROP | grep "windowsmgr.max_events_per_sec=60" | wc -l) -gt 0 ]; then
     echo " 6 - Improve scrolling in lists = applied"
else
     echo " 6 - Improve scrolling in lists"
fi;
if [ $(cat $BPROP | grep "debug.sf.nobootanimation=1" | wc -l) -gt 0 ]; then
     echo " 7 - Disable bootanimation = applied"
else
     echo " 7 - Disable bootanimation"
fi;
echo " 8 - Backup old build.prop"
echo " 9 - Restore old build.prop"
echo
echo " r - Reboot (apply changes)"
echo " b - Back"
echo
echo -n "Please enter your choice: "; read buildprop;
case "$buildprop" in
    "1")
    if [ $(cat $BPROP | grep "debug.sf.hw=0" | wc -l) -gt 0 ]; then
         sed -i '/debug.sf.hw=*/ d' $BPROP;
         echo "debug.sf.hw=1" >> $BPROP;
         echo
         echo "UI rendering with GPU ENABLED";
         buildpropmenu;
    else
         sed -i '/debug.sf.hw=*/ d' $BPROP;
         echo "debug.sf.hw=0" >> $BPROP;
         echo
         echo "UI rendering with GPU DISABLED";
         buildpropmenu;
    fi ;;
    "2")
    if [ -e /data/build.prop.bak ]; then
         sed -i '/ro.media.enc.jpeg.quality=*/ d' $BPROP;
         echo "ro.media.enc.jpeg.quality=100" >> $BPROP;
         buildpropmenu;
    else
         echo
         echo "There is no backup off your build.prop";
         sleep 2;
         buildpropmenu;
    fi ;;
    "3")
    if [ -e /data/build.prop.bak ]; then
         sed -i '/wifi.supplicant_scan_interval=*/ d' $BPROP;
         echo "wifi.supplicant_scan_interval=60" >> $BPROP;
         buildpropmenu;
    else
         echo
         echo "There is no backup off your build.prop";
         sleep 2;
         buildpropmenu;
    fi ;;
    "4")
    if [ -e /data/build.prop.bak ]; then
         sed -i '/ro.HOME_APP_ADJ=*/ d' $BPROP;
         echo "ro.HOME_APP_ADJ=1" >> $BPROP;
         buildpropmenu;
    else
         echo
         echo "There is no backup off your build.prop";
         sleep 2;
         buildpropmenu;
    fi ;;
    "5")
    if [ -e /data/build.prop.bak ]; then
         sed -i '/ro.telephony.call_ring.delay=*/ d' $BPROP;
         echo "ro.telephony.call_ring.delay=0" >> $BPROP;
         buildpropmenu;
    else
         echo
         echo "There is no backup off your build.prop";
         sleep 2;
         buildpropmenu;
    fi ;;
    "6")
    if [ -e /data/build.prop.bak ]; then
         sed -i '/windowsmgr.max_events_per_sec=*/ d' $BPROP;
         echo "windowsmgr.max_events_per_sec=60" >> $BPROP;
         buildpropmenu;
    else
         echo
         echo "There is no backup off your build.prop";
         sleep 2;
         buildpropmenu;
    fi ;;
    "7")
    if [ -e /data/build.prop.bak ]; then
         sed -i '/debug.sf.nobootanimation=*/ d' $BPROP;
         echo "debug.sf.nobootanimation=1" >> $BPROP;
         buildpropmenu;
    else
         echo
         echo "There is no backup off your build.prop";
         sleep 2;
         buildpropmenu;
    fi ;;
    "8")
    if [ -e /data/build.prop.bak ]; then
         echo
         echo "There is already a backup"
         echo "Do you want to overwrite it?"
         echo "[y/n]"
         buildpropmenu;
    else
         cp $BPROP /data/build.prop.bak
         echo
         echo "Backup created"
         sleep 2
         buildpropmenu;
    fi ;;
    "9")
    if [ -e /data/build.prop.bak ]; then
         rm -f /system/build.prop
         cp /data/build.prop.bak $BPROP
         echo
         echo "Restored back-up!"
         sleep 2
         buildpropmenu;
    else
         echo
         echo "There is no backup"
         sleep 2
         buildpropmenu;
    fi ;;
    "r" | "R") reboot;;
    "b" | "b") entry;;
esac

case "$bpropbackup" in
  "y" | "Y")
  cp $BPROP /data/build.prop.bak
  echo
  echo "New backup created"
  sleep 2
  buildpropmenu;;
  "n" | "N") buildpropmenu;;
esac
}

# -------------------------------------------------------------------------
# Engengis settings menu
# -------------------------------------------------------------------------
settingsmenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Tweak settings"
echo " 2 - User settings"
echo " 3 - Log options"
echo " 4 - Uninstall Engengis"
echo " 5 - Reset engengis"
echo " 6 - Version information"
echo " b - Back"
echo
echo -n "Please enter your choice: "; read menu;
case "$menu" in
  "1") tweaksettingsmenu;;
  "2") usersettingsmenu;;
  "3") logoptions;;
  "4") uninstallengengis;;
  "5") resetengengis;;
  "6") versioninformation;;
  "b" | "B") entry;;
  "r" | "R") reboot ;;
esac
}

tweaksettingsmenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Disable all tweaks"
echo " 2 - Load tweaks from settings file"
echo " 3 - Enable recommended settings"
echo " b - Back"
echo
echo -n "Please enter your choice: "; read menusettingstweak;

case "$menusettingstweak" in
  "1") disablealltweaks;;
  "2") restorefromfile;;
  "3") setrecommendedsettings;;
  "b" | "B") settingsmenu;;
esac
}

usersettingsmenu () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
if [ $(cat $CONFIG | grep "otasupport=on" | wc -l) -gt 0 ]; then
     echo " 1 - Disable OTA update support"
else
     echo " 1 - Enable OTA update support"
fi;
if [ $(cat $CONFIG | grep "automaticrestore=on" | wc -l) -gt 0 ]; then
     echo " 2 - Disable automatic restore"
else
     echo " 2 - Enable automatic restore"
fi;
if [ $(cat $CONFIG | grep "passwordprotection=on" | wc -l) -gt 0 ]; then
     echo " 3 - Disable password protection"
else
     echo " 3 - Enable password protection"
fi;
if [ $(cat $CONFIG | grep "passwordprotection=on" | wc -l) -gt 0 ]; then
     echo " 4 - Reset password"
fi;
echo " b - Back"
echo 
echo -n "Please enter your choice: "; read menusettingsuser;

case "$menusettingsuser" in
  "1")
  if [ $(cat $CONFIG | grep "otasupport=on" | wc -l) -gt 0 ]; then
        sed -i '/otasupport=*/ d' $CONFIG
        echo "otasupport=off" >> $CONFIG
  else
        sed -i '/otasupport=*/ d' $CONFIG
        echo "otasupport=on" >> $CONFIG
  fi;
  usersettingsmenu;;
  "2")
  if [ $(cat $CONFIG | grep "automaticrestore=on" | wc -l) -gt 0 ]; then
        sed -i '/automaticrestore=*/ d' $CONFIG
        echo "automaticrestore=off" >> $CONFIG
  else
        sed -i '/automaticrestore=*/ d' $CONFIG
        echo "automaticrestore=on" >> $CONFIG
  fi;
  usersettingsmenu;;
  "3")
  if [ $(cat $CONFIG | grep "passwordprotection=on" | wc -l) -gt 0 ]; then
        sed -i '/passwordprotection=*/ d' $CONFIG
        echo "passwordprotection=off" >> $CONFIG
        rm -rf /data/engengis-user
        usersettingsmenu;
  else
        sed -i '/passwordprotection=*/ d' $CONFIG
        echo "passwordprotection=on" >> $CONFIG
        check_password;
  fi;;
  "4")
  if [ $(cat $CONFIG | grep "passwordprotection=on" | wc -l) -gt 0 ]; then
        rm -rf /data/engengis-user
        check_password;
  else
        usersettingsmenu;
  fi;;
  "b" | "B") settingsmenu;;
esac
}

disablealltweaks () {
clear
echo "The following tweaks are enabled:"
echo
cat $SETTINGS
echo
echo "Do you want to disable them all?"
echo "[y/n]"
read disablealltweaksoption;

case "$disablealltweaksoption" in
  "y" | "Y")
  if [ -e $SYSTEMTWEAK]; then
      rm -f $SYSTEMTWEAK
      echo "Systemtweak DISABLED"
  fi;
  if [ -e $HSSTWEAK]; then
      rm -f $HSSTWEAK
      echo "HSS Systemtweak DISABLED"
  fi;
  if [ -e $ZIPALIGN ]; then
      rm -f $ZIPALIGN;
      echo "Zipalign during boot DISABLED";
      sed -i '/zipalignduringboot=*/ d' $SETTINGS;
      echo "zipalignduringboot=off" >> $SETTINGS;
  fi;
  if [ -e $DROPCACHES ]; then
      rm -f $DROPCACHES;
      echo "Drop caches during boot DISABLED";
      sed -i '/dropcachesduringboot=*/ d' $SETTINGS;
      echo "dropcachesduringboot=off" >> $SETTINGS;
  fi;
  if [ -e $INTSPEED ]; then
      rm -f $INTSPEED;
      echo "Internetspeed tweak DISABLED";
      sed -i '/internetspeed=*/ d' $SETTINGS;
      echo "internetspeed=off" >> $SETTINGS;
  fi;
  if [ -e $INTSECURE ]; then
      rm -f $INTSECURE;
      echo "Internetsecurity tweak DISABLED";
      sed -i '/internetsecurity=*/ d' $SETTINGS;
      echo "internetsecurity=off" >> $SETTINGS;
  fi;
  if [ -e $SCHEDULER ]; then
      rm -f $SCHEDULER;
      echo "Removed scheduler settings";
      sed -i '/ioscheduler=*/ d' $SETTINGS;
      echo "ioscheduler=default" >> $SETTINGS;
  fi;
  if [ -e $READSPEED ]; then
      rm -f $READSPEED;
      echo "Removed SD-Readspeed settings";
      sed -i '/sdreadspeed=*/ d' $SETTINGS;
      echo "sdreadspeed=default" >> $SETTINGS;
  fi;
  if [ -e $CPUGTWEAK ]; then
      rm -f $CPUGTWEAK;
      echo "Governortweak DISABLED";
      sed -i '/governortweak=*/ d' $SETTINGS;
      echo "governortweak=off" >> $SETTINGS;
  fi;
  if [ -e $GOVERNOR ]; then
      rm -f $GOVERNOR;
      echo "Removed governor settings";
  fi;
  sleep 3
  tweaksettingsmenu;;
  "n" | "N") tweaksettingsmenu;;
esac
}

restorefromfile () {
clear 
echo "The following tweaks are loaded in the settings file:"
echo
cat $SETTINGS
echo 
echo "Do you want to enable these settings?"
echo "[y/n]"
read restoretweaks

case "$restoretweaks" in
  "y" | "Y")
  if [ $(cat $SETTINGS | grep "zipalignduringboot=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S14zipalign $ZIPALIGN;
       chmod 777 $ZIPALIGN;
  fi;
  if [ $(cat $SETTINGS | grep "dropcachesduringboot=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S49dropcaches $DROPCACHES;
       chmod 777 $DROPCACHES;
  fi;
  if [ $(cat $SETTINGS | grep "internetspeed=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S56internet $INTSPEED;
       chmod 777 $INTSPEED;
  fi;
  if [ $(cat $SETTINGS | grep "internetsecurity=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S63internetsecurity $INTSECURE;
       chmod 777 $INTSECURE;
  fi;
  if [ $(cat $SETTINGS | grep "governortweak=on" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S21governortweak $CPUGTWEAK;
       chmod 777 $CPUGTWEAK;
  fi;
  if [ $(cat $SETTINGS | grep "ioscheduler=bfq" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S28bfqscheduler $SCHEDULER;
       chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=cfq" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28cfqscheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=deadline" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28deadlinescheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=noop" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28noopscheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=vr" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28vrscheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  elif [ $(cat $SETTINGS | grep "ioscheduler=sio" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S28sioscheduler $SCHEDULER;
         chmod 777 $SCHEDULER;
  fi;
  if [ $(cat $SETTINGS | grep "sdreadspeed=256" | wc -l) -gt 0 ]; then
       cp /system/etc/engengis/S35sd256 $READSPEED;
       chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=512" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd512 $READSPEED;
         chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=1024" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd1024 $READSPEED;
         chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=2048" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd2048 $READSPEED;
         chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=3072" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd3072 $READSPEED;
         chmod 777 $READSPEED;
  elif [ $(cat $SETTINGS | grep "sdreadspeed=4096" | wc -l) -gt 0 ]; then
         cp /system/etc/engengis/S35sd4096 $READSPEED;
         chmod 777 $READSPEED;
  fi;
  tweaksettingsmenu;;
  "n" | "N") tweaksettingsmenu;;
esac
}

setrecommendedsettings () {
clear
echo "Do you want to remove your current tweaks?"
echo "And enable the following?"
echo
echo "- Zipalign during boot"
echo "- Dropcaches during boot"
echo "- SD readspeed 256kb"
echo "- Internet speed tweaks"
echo 
echo "[y/n]"
read recommendedsettings

case "$recommendedsettings" in
  "y" | "Y")
  rm -f $SETTINGS
  rm -f /system/etc/init.d/S00systemtweak
  rm -f /system/etc/init.d/S00ramscript
  rm -f /system/etc/init.d/S07hsstweak
  rm -f /system/etc/init.d/S14zipalign
  rm -f /system/etc/init.d/S21sqlite
  rm -f /system/etc/init.d/S21hsstweak
  rm -f /system/etc/init.d/S21governortweak
  rm -f /system/etc/init.d/S28scheduler
  rm -f /system/etc/init.d/S35sdreadspeed
  rm -f /system/etc/init.d/S42cpugovernor
  rm -f /system/etc/init.d/S49dropcaches
  rm -f /system/etc/init.d/S56internet
  rm -f /system/etc/init.d/S63internetsecurity
  touch $SETTINGS
  cp /system/etc/engengis/S14zipalign $ZIPALIGN;
  chmod 777 $ZIPALIGN;
  sed -i '/zipalignduringboot=*/ d' $SETTINGS;
  echo "zipalignduringboot=on" >> $SETTINGS;
  cp /system/etc/engengis/S49dropcaches $DROPCACHES;
  chmod 777 $DROPCACHES;
  sed -i '/dropcachesduringboot=*/ d' $SETTINGS;
  echo "dropcachesduringboot=on" >> $SETTINGS;
  cp /system/etc/engengis/S35sd256 $READSPEED;
  chmod 777 $READSPEED;
  sed -i '/sdreadspeed=*/ d' $SETTINGS;
  echo "sdreadspeed=256" >> $SETTINGS;
  cp /system/etc/engengis/S56internet $INTSPEED;
  chmod 777 $INTSPEED;
  sed -i '/internetspeed=*/ d' $SETTINGS;
  echo "internetspeed=on" >> $SETTINGS;
  echo "internetsecurity=off" >> $SETTINGS;
  echo "ioscheduler=default" >> $SETTINGS;
  echo "governortweak=off" >> $SETTINGS
  clear
  echo "Recommended tweaks are now ENABLED";
  sleep 2;  tweaksettingsmenu;;
  "n" | "N") tweaksettingsmenu;;
esac
}

logoptions () {
clear
echo
echo " 1 - View log"
echo " 2 - Remove log"
echo " b - back"
echo
echo "Please enter your choice: "; read log;

case "$log" in
  "1")
  cp $LOG /sdcard/engengis.log
  echo "Find log on /sdcard/engengis.log"
  sleep 2
  settingsmenu;;
  "2")
  rm -f $LOG
  echo "Log removed"
  sleep 2
  settingsmenu;;
  "b" | "B") settingsmenu;;
esac
}

uninstallengengis () {
clear
echo
echo " 1 - Unistall engengis files on /system"
echo " 2 - Unistall all engengis files (system + data)"
echo " b - Back"
echo
echo "Please enter your choice: "; read engengis;

case "$engengis" in
  "1")
  rm -rf /system/etc/engengis
  rm -f /system/etc/init.d/S00systemtweak
  rm -f /system/etc/init.d/S00ramscript
  rm -f /system/etc/init.d/S07hsstweak
  rm -f /system/etc/init.d/S14zipalign
  rm -f /system/etc/init.d/S21sqlite
  rm -f /system/etc/init.d/S21hsstweak
  rm -f /system/etc/init.d/S21governortweak
  rm -f /system/etc/init.d/S28scheduler
  rm -f /system/etc/init.d/S35sdreadspeed
  rm -f /system/etc/init.d/S42cpugovernor
  rm -f /system/etc/init.d/S49dropcaches
  rm -f /system/etc/init.d/S56internet
  rm -f /system/etc/init.d/S63internetsecurity
  rm -f /system/bin/engengis
  rm -f /system/bin/engengisg
  rm -f /system/bin/engengisr
  rm -f /system/bin/engengiss
  rm -f /system/bin/engengishss
  rm -f /system/bin/engengissettings
  echo
  echo "Uninstalled engengis! Phone will reboot!"
  sleep 2
  reboot 
  ;;
  "2")
  rm -rf /system/etc/engengis
  rm -rf /sdcard/engengis
  rm -rf /data/engengis-user
  rm -f /system/etc/init.d/S00systemtweak
  rm -f /system/etc/init.d/S00ramscript
  rm -f /system/etc/init.d/S07hsstweak
  rm -f /system/etc/init.d/S14zipalign
  rm -f /system/etc/init.d/S21sqlite
  rm -f /system/etc/init.d/S21hsstweak
  rm -f /system/etc/init.d/S21governortweak
  rm -f /system/etc/init.d/S28scheduler
  rm -f /system/etc/init.d/S35sdreadspeed
  rm -f /system/etc/init.d/S42cpugovernor
  rm -f /system/etc/init.d/S49dropcaches
  rm -f /system/etc/init.d/S56internet
  rm -f /system/etc/init.d/S63internetsecurity
  rm -f /system/bin/engengis
  rm -f /system/bin/engengisg
  rm -f /system/bin/engengisr
  rm -f /system/bin/engengiss
  rm -f /system/bin/engengishss
  rm -f /system/bin/engengissettings
  rm -f $CONFIG
  rm -f $LOG
  rm -f $SETTINGS
  rm -f $TEMP
  rm -f /data/build.prop.bak
  rm -f /sdcard/engengis-scripts/placeholder
  echo
  echo "Uninstalled engengis! Phone will reboot!"
  sleep 2
  reboot 
  ;;
  "b" | "B") settingsmenu;;
esac
}

resetengengis () {
clear
echo
echo " 1 - Reset usertype"
echo " 2 - Reset all settings"
echo " b - Back"
echo
echo "Please enter your choice: "; read reset;

case "$reset" in
  "1")
  sed -i '/user=*/ d' $CONFIG
  echo
  echo "Usertype has been reset"
  echo "Engengis will reconfigure usertype in a few seconds."
  sleep 2
  user; settingsmenu;; 
  "2")
  rm -f $LOG
  rm -f $CONFIG
  rm -f $SETTINGS
  rm -f $TEMP
  rm -f /sdcard/engengis-scripts/on
  rm -rf /sdcard/engengis
  rm -rf /data/engengis-user
  rm -f /system/etc/init.d/S00ramscript
  rm -f /system/etc/init.d/S00systemtweak
  rm -f /system/etc/init.d/S07hsstweak
  rm -f /system/etc/init.d/S14zipalign
  rm -f /system/etc/init.d/S21hsstweak
  rm -f /system/etc/init.d/S21governortweak
  rm -f /system/etc/init.d/S28scheduler
  rm -f /system/etc/init.d/S35sdreadspeed
  rm -f /system/etc/init.d/S42cpugovernor
  rm -f /system/etc/init.d/S49dropcaches
  rm -f /system/etc/init.d/S56internet
  rm -f /system/etc/init.d/S63internetsecurity
  echo "Removed data..."
  echo "Engengis will reconfigure itself in a few seconds."
  sleep 2
  check; user; check_password; entry;;
  "b" | "B") settingsmenu;;
esac
}

versioninformation () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " Version = $VERSION"
echo " Codename = $CODENAME"
echo " Author = Redmaner"
echo " Status = $STATUS"
echo " Official = $OFFICIAL"
echo
echo -n "Press c to continue: "; read version

case "$version" in
  "c" | "C") settingsmenu;;
esac
}

# -------------------------------------------------------------------------
# Configure systemtweak
# -------------------------------------------------------------------------
systemtweak_config () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
if [ -e $SYSTEMTWEAK ]; then
     echo " 1 - Disable systemtweak"
elif [ -e $HSSTWEAK ]; then
     echo " 1 - Disable HSS tweak"
else 
     echo " 1 - Enable systemtweak/hss"
fi;
if [ -e $SYSTEMTWEAK ]; then
     echo " 2 - Configure systemtweak (normal)"
     if [ $(cat $CONFIG | grep "user=advanced" | wc -l) -gt 0 ]; then
          echo " 3 - Configure systemtweak (advanced users)"
     fi;
fi;
echo " b - Back"
echo
echo -n "Please enter your choice: "; read rammain;
case "$rammain" in
  "1")
  if [ -e $SYSTEMTWEAK ]; then
       rm -f $SYSTEMTWEAK; systemtweak_config;
  elif [ -e $HSSTWEAK ]; then
       rm -f $HSSTWEAK; systemtweak_config;
  else
       clear
       echo "You can enable two types of systemtweaks"
       echo
       echo " 1 - Configureable systemtweak"
       echo " 2 - HSS systemtweak"
       echo
       echo -n "Please enter your choise: "; read systemtweakoption;
  fi;;
  "2") systemtweak_config_swap;;
  "3")
  if [ $(cat $CONFIG | grep "user=advanced" | wc -l) -gt 0 ]; then
      systemtweak_config_advanced;
  else
      systemtweak_config;
  fi;;
  "b" | "B") 
  if [ $(cat $TEMP | grep "entry" | wc -l) -gt 0 ]; then
       rm -f $TEMP
       entry;
  elif [ $(cat $TEMP | grep "systemtweaksmenu" | wc -l) -gt 0 ]; then
       rm -f $TEMP
       systemtweaksmenu;
  else
       entry;
  fi;;
esac

case "$systemtweakoption" in
  "1") 
   rm -f $HSSTWEAK
   cp /system/etc/engengis/S00systemtweak $SYSTEMTWEAK
   chmod 777 $SYSTEMTWEAK
   systemtweak_config;;
   "2")
   rm -f $SYSTEMTWEAK
   cp /system/etc/engengis/S07hsstweak $HSSTWEAK
   chmod 777 $HSSTWEAK
   systemtweak_config;;
esac

}

systemtweak_config_advanced () {
clear
cp /system/etc/engengis/S00systemtweak $SYSTEMTWEAK
chmod 777 $SYSTEMTWEAK
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " NOTICE! only numbers allowed!"
echo
echo -n "Please enter a value for swappiness: "; read swappiness_input;
echo -n "Please enter a value for vfs_cache_pressure: "; read vfs_cache_pressure_input;
echo -n "Please enter a value for dirty_ratio: "; read dirty_ratio_input;
echo -n "Please enter a value for dirty_background_ratio: "; read dirty_background_ratio_input;
echo -n "Please enter a value for dirty_expire_centisecs: "; read dirty_expire_centisecs_input;
echo -n "Please enter a value for dirty_writeback_centisecs: "; read dirty_writeback_centisecs_input;
echo
clear
echo "Your input was: "
echo
echo "swappiness = $swappiness_input";
echo "vfs_cache_pressure = $vfs_cache_pressure_input";
echo "dirty_ratio = $dirty_ratio_input";
echo "dirty_background_ratio = $dirty_background_ratio_input";
echo "dirty_expire_centisecs = $dirty_expire_centisecs_input";
echo "dirty_writeback_centisecs = $dirty_writeback_centisecs_input";
echo
echo "Are you sure you want to continue with these values?"
echo "[y/n]"; read advanced_systemtweak_config_choice;

case "$advanced_systemtweak_config_choice" in
  "y" | "Y") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/swappiness ]; then
      echo "$swappiness_input" > /proc/sys/vm/swappiness
fi;
if [ -e /proc/sys/vm/vfs_cache_pressure ]; then
      echo "$vfs_cache_pressure_input" > /proc/sys/vm/vfs_cache_pressure
fi;
if [ -e /proc/sys/vm/dirty_ratio ]; then
      echo "$dirty_ratio_input" > /proc/sys/vm/dirty_ratio
fi;
if [ -e /proc/sys/vm/dirty_background_ratio ]; then
      echo "$dirty_background_ratio_input" > /proc/sys/vm/dirty_background_ratio
fi;
if [ -e /proc/sys/vm/dirty_expire_centisecs ]; then
      echo "$dirty_expire_centisecs_input" > /proc/sys/vm/dirty_expire_centisecs
fi;
if [ -e /proc/sys/vm/dirty_writeback_centisecs ]; then
      echo "$dirty_writeback_centisecs_input" > /proc/sys/vm/dirty_writeback_centisecs
fi;
EOF
  echo "Settings applied"
  sleep 2; systemtweak_config_lmk;;
  "n" | "N") systemtweak_config;;
esac
}

systemtweak_config_swap () {
clear
cp /system/etc/engengis/S00systemtweak $SYSTEMTWEAK
chmod 777 $SYSTEMTWEAK
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Swap Agressive"
echo " 2 - Swap Normal"
echo " 3 - Swap None"
echo " b - Device default"
echo
echo -n "Please enter your choice: "; read ramswap;

case "$ramswap" in
  "1") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/swappiness ]; then
      echo "100" > /proc/sys/vm/swappiness
fi;
if [ -e /proc/sys/vm/vfs_cache_pressure ]; then
      echo "140" > /proc/sys/vm/vfs_cache_pressure
fi;
EOF
  systemtweak_config_dirtyratio;;
  "2") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/swappiness ]; then
      echo "60" > /proc/sys/vm/swappiness
fi;
if [ -e /proc/sys/vm/vfs_cache_pressure ]; then
      echo "100" > /proc/sys/vm/vfs_cache_pressure
fi;
EOF
  systemtweak_config_dirtyratio;;
  "3") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/swappiness ]; then
      echo "0" > /proc/sys/vm/swappiness
fi;
if [ -e /proc/sys/vm/vfs_cache_pressure ]; then
      echo "10" > /proc/sys/vm/vfs_cache_pressure
fi;
EOF
  systemtweak_config_dirtyratio;;
  "b" | "B") systemtweak_config_dirtyratio;;
esac
}

systemtweak_config_dirtyratio () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Dirtyratio 90 - 70"
echo " 2 - Dirtyratio 75 - 50"
echo " 3 - Dirtyratio 10 - 6"
echo " b - Device default"
echo
echo -n "Please enter your choice: "; read ramdirty;
case "$ramdirty" in

  "1") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/dirty_ratio ]; then
      echo "90" > /proc/sys/vm/dirty_ratio
fi;
if [ -e /proc/sys/vm/dirty_background_ratio ]; then
      echo "70" > /proc/sys/vm/dirty_background_ratio
fi;
EOF
  systemtweak_config_writeback;;
  "2") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/dirty_ratio ]; then
      echo "75" > /proc/sys/vm/dirty_ratio
fi;
if [ -e /proc/sys/vm/dirty_background_ratio ]; then
      echo "50" > /proc/sys/vm/dirty_background_ratio
fi;
EOF
  systemtweak_config_writeback;;
  "3") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/dirty_ratio ]; then
      echo "10" > /proc/sys/vm/dirty_ratio
fi;
if [ -e /proc/sys/vm/dirty_background_ratio ]; then
      echo "6" > /proc/sys/vm/dirty_background_ratio
fi;
EOF
  systemtweak_config_writeback;;
  "b" | "B") systemtweak_config_writeback;;
esac
}

systemtweak_config_writeback () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Expire/writeback = Battery"
echo " 2 - Expire/writeback = Performance"
echo " 3 - Expire/writeback = Normal"
echo " b - Device default"
echo
echo -n "Please enter your choice: "; read ramwriteback;

case "$ramwriteback" in
  "1") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/dirty_expire_centisecs ]; then
      echo "1000" > /proc/sys/vm/dirty_expire_centisecs
fi;
if [ -e /proc/sys/vm/dirty_writeback_centisecs ]; then
      echo "2000" > /proc/sys/vm/dirty_writeback_centisecs
fi;
EOF
  systemtweak_config_lmk;;
  "2") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/dirty_expire_centisecs ]; then
      echo "500" > /proc/sys/vm/dirty_expire_centisecs
fi;
if [ -e /proc/sys/vm/dirty_writeback_centisecs ]; then
      echo "1000" > /proc/sys/vm/dirty_writeback_centisecs
fi;
EOF
  systemtweak_config_lmk;;
  "3") cat >> $SYSTEMTWEAK << EOF
if [ -e /proc/sys/vm/dirty_expire_centisecs ]; then
      echo "200" > /proc/sys/vm/dirty_expire_centisecs
fi;
if [ -e /proc/sys/vm/dirty_writeback_centisecs ]; then
      echo "500" > /proc/sys/vm/dirty_writeback_centisecs
fi;
EOF
  systemtweak_config_lmk;;
  "b" | "B") systemtweak_config_lmk;;
esac
}

systemtweak_config_lmk () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - LowMemoryKiller Agressive"
echo " 2 - LowMemoryKiller Performance"
echo " 3 - LowMemoryKiller Normal"
echo " b - Device default"
echo
echo -n "Please enter your choice: "; read ramlmk;
case "$ramlmk" in
  "1") cat >> $SYSTEMTWEAK << EOF

# Lowmemorykiller (lmk + adj)
if [ -e /sys/module/lowmemorykiller/parameters/adj ]; then
      echo "0,1,2,4,9,15" > /sys/module/lowmemorykiller/parameters/adj;
fi;
if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then
      echo "8192,10240,12288,14336,16384,20480" > /sys/module/lowmemorykiller/parameters/minfree;
fi; 
EOF
  systemtweak_config;;
  "2") cat >> $SYSTEMTWEAK << EOF

# Lowmemorykiller (lmk + adj)
if [ -e /sys/module/lowmemorykiller/parameters/adj ]; then
      echo "0,1,2,6,8,15" > /sys/module/lowmemorykiller/parameters/adj;
fi;
if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then
      echo "2048,4096,6144,11264,13312,15360" > /sys/module/lowmemorykiller/parameters/minfree;
fi;
EOF
  systemtweak_config;;
  "3") cat >> $SYSTEMTWEAK << EOF

# Lowmemorykiller (lmk + adj)
if [ -e /sys/module/lowmemorykiller/parameters/adj ]; then
      echo "0,1,2,4,6,15" > /sys/module/lowmemorykiller/parameters/adj;
fi;
if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then
      echo "2048,3072,4096,6144,7168,8192" > /sys/module/lowmemorykiller/parameters/minfree;
fi;
EOF
  systemtweak_config;;
  "b" | "B") systemtweak_config;;
esac
}

# -------------------------------------------------------------------------
# Script Manager
# -------------------------------------------------------------------------
script_manager () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo " 1 - Script remover"
if [ -e /sdcard/engengis-scripts/placeholder ]; then
   echo " 2 - Script installer"
else
   echo " 2 - Enable script installer"
fi;
echo " b - Back"
echo
echo "Please enter your choice: "; read script_manager_choice;

case "$script_manager_choice" in
  "1") script_remover;;
  "2")
  if [ -e /sdcard/engengis-scripts/placeholder ]; then
       scriptinstaller;
  elif [ -d /sdcard/engengis-scripts ]; then
       touch /sdcard/engengis-scripts/placeholder
       echo
       echo "Enabled script intaller"
       sleep 2
       script_manager;
  else
       mkdir -p /sdcard/engengis-scripts
       touch /sdcard/engengis-scripts/placeholder
       echo
       echo "Enabled script intaller"
       sleep 2
       script_manager;
  fi;;
  "b" | "B") entry;;
esac
}

script_remover () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo "Detected the following files:"
echo "-------------"
echo
ls /system/etc/init.d
echo
echo "-------------"
echo " 1 - Remove all scripts"
echo " 2 - Remove one script"
if [ $(cat $CONFIG | grep "user=advanced" | wc -l) -gt 0 ]; then
     echo " 3 - Set up own path for remover"
fi;
echo " b - Back"
echo
echo -n "Please enter your choice: "; read remove_menu;

case "$remove_menu" in
  "1")
  rm -rf /system/etc/init.d
  mkdir /system/etc/init.d
  echo
  echo "All scripts are removed"
  sleep 2
  script_remover;;
  "2")
  echo
  echo -n "Please enter a scriptname to remove (b for Back): "; read script_remover_input;
  if [ -e /system/etc/init.d/$script_remover_input ]; then
       if [ $script_remover_input = "b" ]; then
            script_remover;
       fi;
       echo
       echo "You selected: $script_remover_input"
       echo "Are you sure you want to remove it?"
       echo "[y/n]"
       read script_remover_choice
  else
       echo "There was an input error"
       echo "Your input doesn't match any files"
       sleep 2
       script_remover;
  fi;;
  "3") 
  if [ $(cat $CONFIG | grep "user=advanced" | wc -l) -gt 0 ]; then
       script_remover_ownpath_setup;
  else
       script_remover
  fi;;
  "b" | "B") script_manager;;
esac

case "$script_remover_choice" in
  "y" | "Y")
  rm -f /system/etc/init.d/$script_remover_input
  echo
  echo "$script_remover_input removed"
  sleep 2
  script_remover;;
  "n" | "N") script_remover;;
esac
}

script_remover_ownpath_setup () {
clear
echo
echo -n "Please give path to start remover: "; read remover_input_path;
script_remover_ownpath;
}

script_remover_ownpath () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo "Detected the following files:"
echo "-------------"
echo
ls $remover_input_path
echo
echo "-------------"
echo -n "Please enter a scriptname to remove (b for Back): "; read script_remover_input_path;
if [ -e $remover_input_path/$script_remover_input_path ]; then
     if [ $script_remover_input_path = "b" ]; then
          script_remover_ownpath;
     fi;
     echo
     echo "You selected: $script_remover_input_path"
     echo "Are you sure you want to remove it?"
     echo "[y/n]"
     read script_remover_choice_path
else
     echo "There was an input error"
     echo "Your input doesn't match any files"
     sleep 2
     script_remover_ownpath;
fi;

case "$script_remover_choice_path" in
  "y" | "Y")
  rm -f $remover_input_path/$script_remover_input_path
  echo
  echo "$script_remover_input_path removed"
  sleep 2
  script_remover_ownpath;;
  "n" | "N") script_remover_ownpath;;
esac
}

scriptinstaller () {
clear
echo
echo "------------------------"
echo "Engengis.$CODENAME" 
echo "------------------------"
echo
echo "Detected the following files:"
echo "-------------"
echo
ls /sdcard/engengis-scripts
echo
echo "-------------"
echo " b - Back"
echo
echo -n "Please enter a scriptname to install: "; read script_installer_input;
clear
echo
if [ $script_installer_input = "b" ]; then
     script_manager;
fi;
if [ -e /sdcard/engengis-scripts/$script_installer_input ]; then
     echo "You selected: $script_installer_input"
     echo
     echo "You have a few options:"
     echo " 1 - Execute script directly"
     echo " 2 - Install script in init.d folder"
     if [ $(cat $CONFIG | grep "user=advanced" | wc -l) -gt 0 ]; then
          echo " 3 - Set up own path for installation"
     fi;
     echo " b - Back"
     echo
     echo -n "Please enter your option: "; read script_installer_choice;
else
     echo "There was an input error"
     echo "Your input doesn't match any files"
     sleep 2
     scriptinstaller
fi;

case "$script_installer_choice" in
  "1")
  chmod 777 /sdcard/engengis-scripts/$script_installer_input
  sh /sdcard/engengis-scripts/$script_installer_input
  echo
  echo "$script_installer_input executed"
  sleep 2
  scriptinstaller;;
  "2")
  cp /sdcard/engengis-scripts/$script_installer_input /system/etc/init.d/$script_installer_input
  chmod 777 /system/etc/init.d/$script_installer_input
  echo
  echo "$script_installer_input installed in init.d folder"
  sleep 2
  scriptinstaller;;
  "3") 
  if [ $(cat $CONFIG | grep "user=advanced" | wc -l) -gt 0 ]; then
       scriptinstaller_advanced
  else
       scriptinstaller
  fi;;     
  "b"  | "B") scriptinstaller;;
esac
}

scriptinstaller_advanced () {
echo
echo -n "Please enter a path for installation: "; read user_input_path;
echo
echo "You have entered: $user_input_path"
if [ -d $user_input_path ]; then
     echo "$script_installer_input will be installed in $user_input_path"
     echo "Are you sure?"
     echo "[y/n]"
     read install_script_to_path;
else
     echo "The givin path doesn't exists"
     echo "Do you want to create the path and install it?"
     echo "[y/n]"
     read create_path_install_script;  
fi;

case "$install_script_to_path" in
  "y" | "Y")
  cp /sdcard/engengis-scripts/$script_installer_input $user_input_path/$script_installer_input;
  chmod 777 $user_input_path/$script_installer_input;
  echo
  echo "$script_installer_input installed in $user_input_path";
  sleep 2
  scriptinstaller;;
  "n" | "N") scriptinstaller;;
esac

case "$create_path_install_script" in
  "y" | "Y")
  mkdir -p $user_input_path
  cp /sdcard/engengis-scripts/$script_installer_input $user_input_path/$script_installer_input;
  chmod 777 $user_input_path/$script_installer_input;
  echo
  echo "$script_installer_input installed in $user_input_path";
  sleep 2
  scriptinstaller;;
  "n" | "N") scriptinstaller;;
esac
}

# -------------------------------------------------------------------------
check; user; check_password; entry;



