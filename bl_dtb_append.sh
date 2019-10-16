#!/bin/sh

DTB_FILE=${1:-stm32f429-disco.dtb}
BOOTLOADER_FILE=stm32f429i-disco.bin
OUTPUT_FILE=stm32f429i-disco.bindtb

if [ ! -f ${DTB_FILE} ]; then
	echo "dtb file not present"
	exit 1
fi

set -e

make ARCH=arm CROSS_COMPILE=arm-known-linux-gnueabihf- clean
make ARCH=arm CROSS_COMPILE=arm-known-linux-gnueabihf- stm32f429i-disco

BL_SIZE=`ls -l ${BOOTLOADER_FILE} | cut -d ' ' -f5`
let "BL_SIZE = ${BL_SIZE} + 0x08000000"

# echo $BL_SIZE

make ARCH=arm CROSS_COMPILE=arm-known-linux-gnueabihf- clean
make ARCH=arm CROSS_COMPILE=arm-known-linux-gnueabihf- stm32f429i-disco DTB_ADDR=${BL_SIZE}

cat ${BOOTLOADER_FILE} ${DTB_FILE} > ${OUTPUT_FILE}
