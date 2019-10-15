#!/bin/sh

DTB_FILE=${1:-stm32f429-disco.dtb}
BOOTLOADER_FILE=${2:-stm32f429i-disco.bin}
OUTPUT_FILE=stm32f429i-disco.bindtb

if [ ! -f ${DTB_FILE} ]; then
	echo "dtb file not present"
	exit 1
fi

make ARCH=arm CROSS_COMPILE=arm-known-linux-gnueabihf- clean
make ARCH=arm CROSS_COMPILE=arm-known-linux-gnueabihf- stm32f429i-disco DTB_ADDR=0x0800068e

if [ ! -f ${BOOTLOADER_FILE} ]; then
	echo "bootloader file not present"
	exit 1
fi

cat ${BOOTLOADER_FILE} ${DTB_FILE} > ${OUTPUT_FILE}
