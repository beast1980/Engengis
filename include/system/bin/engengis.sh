#!/system/bin/sh
# Copyright (c) 2012 - redmaner 
# Engengis project

# Version information
BUILD=50
VERSION=v0.5.0.6
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

if [ -e $SETTINGS ]; then
    echo "Settings file = Ok" >> $LOG;
else
    touch $SETTINGS
    echo "zipalignduringboot=off" >> $SETTINGS
    echo "dropcachesduringboot=off" >> $SETTINGS
    echo "internetspeed=off" >> $SETTINGS
    echo "ioscheduler=default" >> $SETTINGS
    echo "sdreadspeed=default" >> $SETTINGS
    echo "governortweak=off" >> $SETTINGS
    echo "Settings file created" >> $LOG;
    echo "Settings file created"
    sleep 1
fi;

if [ -e $CONFIG ]; then
    echo "Configuration file = Ok" >> $LOG;
else
    touch $CONFIG
    echo "otasupport=off" >> $CONFIG
    echo "status=firstboot" >> $CONFIG
    echo "Configuration file created" >> $LOG;
    echo "Created configuration file"
    sleep 1
fi;

if [ -e /system/lib/libncurses.so ]; then
    echo "libncurses.so detected" >> $LOG
else
    cp /system/etc/engengis/libncurses.so /system/lib/libncurses.so
    chmod 775 /system/lib/libncurses.so
    echo "Loaded libncurses.so"
    echo "Loaded libncurses.so" >> $LOG
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
  echo "disclaimer=accepted" >> $CONFIG;
  firstboot;;
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
# Check status of engengis
# -------------------------------------------------------------------------
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
  echo "Recommanded tweaks are now ENABLED"
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
  sleep 2
  sed -i '/status=*/ d' $CONFIG;
  echo "status=normal" >> $CONFIG;
  sleep 1
  systemtweak_option;;
  "n" | "N")
  clear
  rm -f $SETTINGS
  touch $SETTINGS
  echo "zipalignduringboot=off" >> $SETTINGS
  echo "dropcachesduringboot=off" >> $SETTINGS
  echo "internetspeed=off" >> $SETTINGS
  echo "ioscheduler=default" >> $SETTINGS
  echo "sdreadspeed=default" >> $SETTINGS
  echo "governortweak=off" >> $SETTINGS
  sed -i '/status=*/ d' $CONFIG;
  echo "status=normal" >> $CONFIG;
  sleep 1
  systemtweak_option;;
esac
}

systemtweak_option () {
clear
echo "Do you want to set your systemtweak now?"
echo "[y/n]"
read optionram
case "$optionram" in
  "y" | "Y") systemtweak_config;;
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
echo "Engengis.Delta" 
echo "------------------------"
echo
echo " 1 - System tweaks" 
echo " 2 - I/O scheduler settings" 
echo " 3 - SD-Readspeed settings"
echo " 4 - CPU governor settings"
echo " 5 - Disply resolution (dpi)"
echo " 6 - Build.prop optimizations"
echo " 7 - Engengis settings"
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
      exit
  fi;;
  "r" | "R") reboot ;;
  "e" | "E") exit ;;
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
echo "Engengis.Delta" 
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
  "1") clear; systemtweak_config;;
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
echo "Engengis.Delta" 
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
echo "Engengis.Delta" 
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
echo "Engengis.Delta" 
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
  "2") setgovernor;;
  "3")
  if [ -e $GOVERNOR ]; then
       rm -f $GOVERNOR
  fi;
  governormenu;;
  "b" | "B") entry;;
  "r" | "R") reboot;;
esac
}

setgovernor () {
clear
echo
echo "Current governor: `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`" 
echo "Governors supported by kernel:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
echo
echo "Please type your governor you want to set: ";
read governorinput;

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
     echo
     echo "Governor set to: $governorinput"
     echo "Do you want to reboot now?"
     echo "[y/n]"
     read governorreboot
else
     echo "Kernel doesn't support $governorinput governor"
     sleep 2
     setgovernor;
fi;

case "$governorreboot" in
  "y" | "Y") reboot;;
  "n" | "N") governormenu;;
esac
}

# -------------------------------------------------------------------------
# Engengis DPI menu
# -------------------------------------------------------------------------
dpimenu () {
clear
echo
echo "------------------------"
echo "Engengis.Delta" 
echo "------------------------"
echo
echo " 1 - Set dpi value"
echo " b - Back"
echo
echo "--------------------------------"
echo "Current:`cat $BPROP | grep "ro.sf.lcd_density=*"`"
echo
echo -n "Please enter your choice: "; read changedpi;
case "$changedpi" in
  "1") setdpi;;
  "b" | "B") entry;;
esac
}

setdpi () {
clear
echo
echo "Please enter your dpi value: "; read dpiinput
echo
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
echo "Engengis.Delta" 
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
echo "Engengis.Delta" 
echo "------------------------"
echo
echo " 1 - Wipe init.d folder"
echo " 2 - Disable all tweaks"
echo " 3 - Load tweaks from settings file"
echo " 4 - Enable recommended settings"
if [ $(cat $CONFIG | grep "otasupport=on" | wc -l) -gt 0 ]; then
     echo " 5 - Disable OTA update support"
else
     echo " 5 - Enable OTA update support"
fi;
echo " 6 - Log options"
echo " 7 - Uninstall Engengis"
echo " 8 - Reset engengis"
echo " 9 - Version information"
echo " b - Back"
echo
echo -n "Please enter your choice: "; read menu;
case "$menu" in
  "1") wipeinitd;;
  "2") disablealltweaks;;
  "3") restorefromfile;;
  "4") setrecommandedsettings;;
  "5")
  if [ $(cat $CONFIG | grep "otasupport=on" | wc -l) -gt 0 ]; then
        sed -i '/otasupport=*/ d' $CONFIG
        echo "otasupport=off" >> $CONFIG
  else
        sed -i '/otasupport=*/ d' $CONFIG
        echo "otasupport=on" >> $CONFIG
  fi;
  settingsmenu;;
  "6") logoptions;;
  "7") uninstallengengis;;
  "8") resetengengis;;
  "9") versioninformation;;
  "b" | "B") entry;;
  "r" | "R") reboot ;;
esac
}

wipeinitd () {
echo
echo "Do you want to wipe init.d folder?"
echo "[y/n]"
read initdwipe

case "$initdwipe" in
  "y" | "Y")
  if [ -d /system/etc/init.d ]; then
       rm -rf /system/etc/init.d
       mkdir /system/etc/init.d
       echo
       echo "init.d wiped! Reboot phone!"
       sleep 2
  else
       echo "init.d folder not found!"
       sleep 2 
  fi;
  settingsmenu;;
  "n" | "N") settingsmenu;;
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
  clear; settingsmenu;;
  "n" | "N") clear; settingsmenu;;
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
  settingsmenu;;
  "n" | "N") settingsmenu;;
esac
}

setrecommandedsettings () {
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
read recommandedsettings

case "$recommandedsettings" in
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
  echo "Recommanded tweaks are now ENABLED";
  sleep 2;  settingsmenu;;
  "n" | "N") settingsmenu;;
esac
}

logoptions () {
clear
echo " 1 - View log"
echo " 2 - Remove log"
echo " b - back"
read log

case "$log" in
  "1")
  cp $LOG /sdcard/engengis/engengis.log
  echo "Find log on /sdcard/engengis/engengis.log"
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
echo " 1 - Unistall engengis files on /system"
echo " 2 - Unistall all engengis files (system + data)"
echo " b - Back"
read engengis

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
  rm -f /data/build.prop.bak
  echo
  echo "Uninstalled engengis! Phone will reboot!"
  sleep 2
  reboot 
  ;;
  "b" | "B") settingsmenu;;
esac
}

resetengengis () {
echo "There are two options you can choose"
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
  rm -rf /sdcard/engengis
  rm -f /system/etc/init.d/S00ramscript
  rm -f /system/etc/init.d/S00systemtweak
  rm -f /system/etc/init.d/S07hsstweak
  rm -f /system/etc/init.d/S14zipalign
  rm -f /system/etc/init.d/S21hsstweak
  rm -f /system/etc/init.d/S28scheduler
  rm -f /system/etc/init.d/S35sdreadspeed
  rm -f /system/etc/init.d/S42cpugovernor
  rm -f /system/etc/init.d/S49dropcaches
  rm -f /system/etc/init.d/S56internet
  rm -f /system/etc/init.d/S63internetsecurity
  echo "Removed data..."
  echo "Engengis will reconfigure itself in a few seconds."
  sleep 2
  check; user; firstboot; entry;;
  "b" | "B") settingsmenu;;
esac
}

versioninformation () {
clear
echo
echo "------------------------"
echo "Engengis.Delta" 
echo "------------------------"
echo
echo " Version = $VERSION"
echo " Codename = $CODENAME"
echo " Author = $AUTHOR"
echo " Status = $STATUS"
echo " Official = $OFFICIAL"
echo
echo -n "Press c to continue:"; read version

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
echo "Engengis.Delta" 
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
  "3") systemtweak_config_advanced;;
  "b" | "B") systemtweak_config_end;;
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
echo
echo "------------------------"
echo "Engengis.Delta" 
echo "------------------------"
echo
echo " NOTICE! only numbers allowed!"
echo
echo -n "Please enter a value for swappiness: "; read swappinessinput;
echo "if [ -e /proc/sys/vm/swappiness ]; then
      echo "$swappinessinput" > /proc/sys/vm/swappiness
fi;" >> $SYSTEMTWEAK
echo -n "Please enter a value for vfs_cache_pressure: "; read vfscachepressureinput;
echo "if [ -e /proc/sys/vm/vfs_cache_pressure ]; then
      echo "$vfscachepressureinput" > /proc/sys/vm/vfs_cache_pressure
fi;" >> $SYSTEMTWEAK
echo -n "Please enter a value for dirty_ratio: "; read dirtyratioinput;
echo "if [ -e /proc/sys/vm/dirty_ratio ]; then
      echo "$dirtyratioinput" > /proc/sys/vm/dirty_ratio
fi;" >> $SYSTEMTWEAK
echo -n "Please enter a value for dirty_background_ratio: "; read dirtybackgroundratioinput;
echo "if [ -e /proc/sys/vm/dirty_background_ratio ]; then
      echo "$dirtybackgroundratioinput" > /proc/sys/vm/dirty_background_ratio
fi;" >> $SYSTEMTWEAK
echo -n "Please enter a value for dirty_expire_centisecs: "; read dirtyexpirecentisecsinput;
echo "if [ -e /proc/sys/vm/dirty_expire_centisecs ]; then
      echo "$dirtyexpirecentisecsinput" > /proc/sys/vm/dirty_expire_centisecs
fi;" >> $SYSTEMTWEAK
echo -n "Please enter a value for dirty_writeback_centisecs: "; read dirtywritebackcentisecsinput;
echo "if [ -e /proc/sys/vm/dirty_writeback_centisecs ]; then
      echo "$dirtywritebackcentisecsinput" > /proc/sys/vm/dirty_writeback_centisecs
fi;" >> $SYSTEMTWEAK
systemtweak_config_lmk;
}

systemtweak_config_swap () {
clear
cp /system/etc/engengis/S00systemtweak $SYSTEMTWEAK
echo
echo "------------------------"
echo "Engengis.Delta" 
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
echo "Engengis.Delta" 
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
echo "Engengis.Delta" 
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
echo "Engengis.Delta" 
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
  systemtweak_config_end;;
  "2") cat >> $SYSTEMTWEAK << EOF

# Lowmemorykiller (lmk + adj)
if [ -e /sys/module/lowmemorykiller/parameters/adj ]; then
      echo "0,1,2,6,8,15" > /sys/module/lowmemorykiller/parameters/adj;
fi;
if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then
      echo "2048,4096,6144,11264,13312,15360" > /sys/module/lowmemorykiller/parameters/minfree;
fi;
EOF
  systemtweak_config_end;;
  "3") cat >> $SYSTEMTWEAK << EOF

# Lowmemorykiller (lmk + adj)
if [ -e /sys/module/lowmemorykiller/parameters/adj ]; then
      echo "0,1,2,4,6,15" > /sys/module/lowmemorykiller/parameters/adj;
fi;
if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then
      echo "2048,3072,4096,6144,7168,8192" > /sys/module/lowmemorykiller/parameters/minfree;
fi;
EOF
  systemtweak_config_end;;
  "b" | "B") systemtweak_config_end;;
esac
}

systemtweak_config_end () {
clear
echo
echo "------------------------"
echo "Engengis.Delta" 
echo "------------------------"
echo
echo " 1 - Back to Engengis main menu"
echo " 2 - Back to Engengis systemtweaks menu"
echo
echo -n "Please enter your choice: "; read ramend;
case "$ramend" in
  "1") entry;;
  "2") systemtweaksmenu;;
esac
}

# -------------------------------------------------------------------------
check; user; firstboot; entry;


