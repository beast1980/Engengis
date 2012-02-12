#!/bin/sh
# Copyright (c) 2012, redmaner
# Engengis build tool
# Version: V3.0

# System requirements
# -----------------------------------------
# - Ubuntu (or any other unix based system)
# - Java (to sign zip file)
# - zip/unzip (apt-get install zip/apt-get install unzip)
# - Md5sum

CONFIG=build.conf

check () {
if [ -e $CONFIG ]; then
    echo "Starting build procedure"
    sleep 1
    start_compile
else
    echo "Run setup-build.sh first"
    sleep 2
    exit
fi;
}

start_compile () {
echo "Creating path please wait..."
sleep 1
mkdir -p build/build/META-INF/com/google/android
mkdir -p build/build/system/bin
mkdir -p build/build/system/etc/engengis
mkdir -p build/build/system/xbin
mkdir -p build/build/data
echo
echo "Starting build...."
sleep 1;
echo "Installing => updated"; cp include/data/updated build/build/data/updated;
echo "Installing => update-binary"; cp include/META-INF/com/google/android/update-binary build/build/META-INF/com/google/android/update-binary; 
echo "Installing => updater-script"; cp include/META-INF/com/google/android/updater-script build/build/META-INF/com/google/android/updater-script; 
echo "Installing => engengis.sh"; cp include/system/bin/engengis.sh build/build/system/bin/engengis;
echo "Installing => libncurses.so"; cp include/system/etc/engengis/libncurses.so build/build/system/etc/engengis/libncurses.so;
echo "Installing => S00systemtweak.sh"; cp include/system/etc/engengis/S00systemtweak.sh build/build/system/etc/engengis/S00systemtweak;
echo "Installing => S07hsstweak.sh"; cp include/system/etc/engengis/S07hsstweak.sh build/build/system/etc/engengis/S07hsstweak;
echo "Installing => S14zipalign.sh"; cp include/system/etc/engengis/S14zipalign.sh build/build/system/etc/engengis/S14zipalign;
echo "Installing => S21governortweak.sh"; cp include/system/etc/engengis/S21governortweak.sh build/build/system/etc/engengis/S21governortweak;
echo "Installing => S28bfqscheduler.sh"; cp include/system/etc/engengis/S28bfqscheduler.sh build/build/system/etc/engengis/S28bfqscheduler;
echo "Installing => S28cfqscheduler.sh"; cp include/system/etc/engengis/S28cfqscheduler.sh build/build/system/etc/engengis/S28cfqscheduler;
echo "Installing => S28deadlinescheduler.sh"; cp include/system/etc/engengis/S28deadlinescheduler.sh build/build/system/etc/engengis/S28deadlinescheduler;
echo "Installing => S28noopscheduler.sh"; cp include/system/etc/engengis/S28noopscheduler.sh build/build/system/etc/engengis/S28noopscheduler;
echo "Installing => S28sioscheduler.sh"; cp include/system/etc/engengis/S28sioscheduler.sh build/build/system/etc/engengis/S28sioscheduler;
echo "Installing => S28vrscheduler.sh"; cp include/system/etc/engengis/S28vrscheduler.sh build/build/system/etc/engengis/S28vrscheduler;
echo "Installing => S35sd256.sh"; cp include/system/etc/engengis/S35sd256.sh build/build/system/etc/engengis/S35sd256;
echo "Installing => S35sd512.sh"; cp include/system/etc/engengis/S35sd512.sh build/build/system/etc/engengis/S35sd512;
echo "Installing => S35sd1024.sh"; cp include/system/etc/engengis/S35sd1024.sh build/build/system/etc/engengis/S35sd1024;
echo "Installing => S35sd2048.sh"; cp include/system/etc/engengis/S35sd2048.sh build/build/system/etc/engengis/S35sd2048;
echo "Installing => S35sd3072.sh"; cp include/system/etc/engengis/S35sd3072.sh build/build/system/etc/engengis/S35sd3072;
echo "Installing => S35sd4096.sh"; cp include/system/etc/engengis/S35sd4096.sh build/build/system/etc/engengis/S35sd4096;
echo "Installing => S49dropcaches.sh"; cp include/system/etc/engengis/S49dropcaches.sh build/build/system/etc/engengis/S49dropcaches;
echo "Installing => S56internet.sh"; cp include/system/etc/engengis/S56internet.sh build/build/system/etc/engengis/S56internet;
echo "Installing => S63internetsecurity.sh"; cp include/system/etc/engengis/S63internetsecurity.sh build/build/system/etc/engengis/S63internetsecurity;
echo "Installing => version"; cp include/system/etc/engengis/version build/build/system/etc/engengis/version;
echo "Installing => sqlite3"; cp include/system/xbin/sqlite3 build/build/system/xbin/sqlite3;
echo "Installing => zipalign"; cp include/system/xbin/zipalign build/build/system/xbin/zipalign;
if [ $(cat $CONFIG | grep "include_terminal=yes" | wc -l) -gt 0 ]; then
    echo "Installing => terminal.sh"; cp extra/terminal.sh build/build/system/etc/engengis/terminal;
fi;
if [ $(cat $CONFIG | grep "include_settingsconfig=yes" | wc -l) -gt 0 ]; then
    echo "Installing => terminal"; cp extra/settings.conf build/build/data/settings.conf;
fi;
if [ $(cat $CONFIG | grep "include_engengisconfig=yes" | wc -l) -gt 0 ]; then
    echo "Installing => terminal"; cp extra/engengis.conf build/build/data/engengis.conf;
fi;
echo
echo "Zipping package..."
sleep 1;
cd build/build
sleep 1
zip -r engengis * 
cd ..
cd ..
echo 
clear
echo "Please type the name off the package: (eg. Engengis.Delta_v0.5.0.6)"
read packagename
echo "Signing package..."
java -jar signzip/signapk.jar signzip/testkey.x509.pem signzip/testkey.pk8 build/build/engengis.zip build/$packagename.zip
rm -rf build/build
if [ $(cat $CONFIG | grep "include_md5sum=yes" | wc -l) -gt 0 ]; then
    echo "Generating md5sum..."
    cd build
    md5sum -t $packagename.zip > $packagename.md5
    cd ..
    sleep 1
fi;
echo
echo "Done find your build at:"
echo "build/$packagename.zip"
if [ $(cat $CONFIG | grep "include_md5sum=yes" | wc -l) -gt 0 ]; then
    echo "build/$packagename.md5"
fi;
sleep 3
echo
echo "End off build progress."
sleep 2
exit
}

check;
