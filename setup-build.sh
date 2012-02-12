#!/bin/sh
# Copyright (c) 2012, redmaner
# Engengis setup build tool

CONFIG=build.conf

check_config () {
if [ -e $CONFIG ]; then
     rm -f $CONFIG
fi;

touch $CONFIG
include_md5sum;
}

include_md5sum () {
echo
echo "Do you want to generate md5sum after build?"
echo "NOTICE works only for linux (for now)"
echo "[y/n]"
read includemd5sum;

case "$includemd5sum" in
  "y" | "Y")
  echo "include_md5sum=yes" >> $CONFIG
  include_terminal;;
  "n" | "N") 
  echo "include_md5sum=no" >> $CONFIG
  include_terminal;;
esac
}

include_terminal () {
echo
echo "Do you want to include engengis terminal?"
echo "[y/n]"
read includeterminal;

case "$includeterminal" in
  "y" | "Y")
  echo "include_terminal=yes" >> $CONFIG
  include_settingsconfig;;
  "n" | "N") 
  echo "include_terminal=no" >> $CONFIG
  include_settingsconfig;;
esac
}

include_settingsconfig () {
echo
echo "Do you want to include pre-build settings.conf file?"
echo "[y/n]"
read includesettingsconfig;

case "$includesettingsconfig" in
  "y" | "Y")
  echo "include_settingsconfig=yes" >> $CONFIG
  include_engengisconfig;;
  "n" | "N") 
  echo "include_settingsconfig=no" >> $CONFIG
  include_engengisconfig;;
esac
}

include_engengisconfig () {
echo
echo "Do you want to include pre-build engengis.conf file?"
echo "[y/n]"
read includeengengisconfig;

case "$includeengengisconfig" in
  "y" | "Y")
  echo "include_engengisconfig=yes" >> $CONFIG
  config_end;;
  "n" | "N") 
  echo "include_engengisconfig=no" >> $CONFIG
  config_end;;
esac
}

config_end () {
echo
echo "build.conf file has been succesfully created"
sleep 2
echo "End off setup"
sleep 2
exit;
}

check_config;
