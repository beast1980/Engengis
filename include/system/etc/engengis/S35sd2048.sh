#!/system/bin/sh
# Copyright (c) 2012, brainmaster
# Copyright (c) 2012, redmaner
# Copyright (c) 2012, Others who found more read_ahead_kb locations

# SD-Readspeed = 2048kb
if [ -e /sys/devices/virtual/bdi/0:18/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/0:18/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/179:0/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/179:0/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/179:8/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/179:8/read_ahead_kb;
fi

if [ -e /sys/devices/virtual/bdi/179:16/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/179:16/read_ahead_kb;
fi

if [ -e /sys/devices/virtual/bdi/179:28/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/179:28/read_ahead_kb;
fi

if [ -e /sys/devices/virtual/bdi/179:33/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/179:33/read_ahead_kb;
fi

if [ -e /sys/devices/virtual/bdi/7:0/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/7:0/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/7:1/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/7:1/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/7:2/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/7:2/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/7:3/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/7:3/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/7:4/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/7:4/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/7:5/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/7:5/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/7:6/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/7:6/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/7:7/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/7:7/read_ahead_kb
fi

if [ -e /sys/devices/virtual/bdi/default/read_ahead_kb ]; then
      echo "2048" > /sys/devices/virtual/bdi/default/read_ahead_kb;
fi


