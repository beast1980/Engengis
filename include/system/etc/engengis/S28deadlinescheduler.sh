#!/system/bin/sh
# Copyright (c) 2012, redmaner

BML=`ls -d /sys/block/bml*`;
MMC=`ls -d /sys/block/mmc*`;
MTD=`ls -d /sys/block/mtd*`;
STL=`ls -d /sys/block/stl*`;
TFSR=`ls -d /sys/block/tfsr*`;
ZRAM=`ls -d /sys/block/zram*`;

# Scheduler = deadline
for i in $BML $MMC $MTD $STL $TFSR $ZRAM; do
	if [ -e $i/queue/scheduler ]; 	then
		echo "deadline" > $i/queue/scheduler; 
	fi;
done;





