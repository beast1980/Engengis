#!/system/bin/sh
# Copyright (c) 2012, redmaner
# Governor tweaks

# Conservative governor
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/up_treshold ]; then
     echo "85" > /sys/devices/system/cpu/cpu0/cpufreq/conservative/up_treshold
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/up_treshold ]; then
     echo "85" > /sys/devices/system/cpu/cpu1/cpufreq/conservative/up_treshold
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/up_treshold ]; then
     echo "85" > /sys/devices/system/cpu/cpufreq/conservative/up_treshold
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/down_treshold ]; then 
     echo "50" > /sys/devices/system/cpu/cpu0/cpufreq/conservative/down_treshold
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/down_treshold ]; then 
     echo "50" > /sys/devices/system/cpu/cpu1/cpufreq/conservative/down_treshold
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/down_treshold ]; then 
     echo "50" > /sys/devices/system/cpu/cpufreq/conservative/down_treshold
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/freq_step ]; then 
     echo "70" > /sys/devices/system/cpu/cpu0/cpufreq/conservative/freq_step
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/freq_step ]; then 
     echo "70" > /sys/devices/system/cpu/cpu1/cpufreq/conservative/freq_step
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/conservative/freq_step ]; then 
     echo "70" > /sys/devices/system/cpu/cpufreq/conservative/freq_step
fi;

# Ondemand
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_treshold ]; then
     echo "85" > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_treshold
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_treshold ]; then
     echo "85" > /sys/devices/system/cpu/cpu1/cpufreq/ondemand/up_treshold
fi;
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_treshold ]; then
     echo "85" > /sys/devices/system/cpu/cpufreq/ondemand/up_treshold
fi;
