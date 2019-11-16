#!/bin/sh

# getopt based on /usr/share/doc/util-linux-2.31.1/getopt/getopt-parse.bash
# Note that we use "$@" to let each command-line parameter expand to a
# separate word. The quotes around "$@" are essential!
# We need TEMP as the 'eval set --' would nuke the return value of getopt.
TEMP=$(getopt -o 'b:d::hk:' --long 'bootloader:,devicetree::,help,kernel:' -n 'flash.sh' -- "$@")
if [ $? -ne 0 ]; then
	echo 'Terminating...' >&2
	exit 1
fi
# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

usage ()
{
 echo "Usage: $0 -b<bootloader path>|--bootloader=<bootloader path> -d<devicetree path>|--devicetree=<devicetree path> -k<kernel path>|--kernel=<kernel path>"
 echo "       Note that bootloader can be made appended dtb one using bl_dtb_append.sh, in that case device tree is not required "
}

while true; do
	case "$1" in
		'-h'|'--help')
			usage
			exit 1
		;;
		'-b'|'--bootloader')
			BOOTLOADER=1
			BOOTLOADER_FILE=$2
			shift 2
			continue
		;;
		'-d'|'--devicetree')
			DEVICETREE=1
			case "$2" in
				'')
				;;
				*)
					DEVICETREE_PATH=$2
				;;
			esac
			shift 2
			continue
		;;
		'-k'|'--kernel')
			KERNEL=1
			KERNEL_PATH=$2
			shift 2
			continue
		;;
		'--')
			shift
			break
		;;
		*)
			echo 'Internal error!' >&2
			exit 1
		;;
	esac
done

if [ -v DEVICETREE ]; then
	if [ ! -v DEVICETREE_PATH ]; then
		if [ -v KERNEL ]; then
			DEVICETREE_PATH=${KERNEL_PATH}/arch/arm/boot/dts
		else
			DEVICETREE_PATH=.
		fi
	fi
fi

if [ -v KERNEL ]; then
	if [ ! -d ${KERNEL_PATH} ]; then
		echo "kernel dir not defined"
		exit 1
	fi
fi

if [ -v DEVICETREE ]; then
	if [ ! -d ${DEVICETREE_PATH} ]; then
		echo "device tree dir not defined"
		exit 1
	fi
fi

if [ -v BOOTLOADER ] && [ ! -f ${BOOTLOADER_FILE} ]; then
	echo "bootloader file not present"
	exit 1
fi

if [ -v BOOTLOADER ]; then
	FLASH_BOOTLOADER="flash write_image erase ${BOOTLOADER_FILE} 0x08000000"
fi

if [ -v DEVICETREE ]; then
	FLASH_DEVICETREE="flash write_image erase ${DEVICETREE_PATH}/stm32f429-disco.dtb 0x08004000"
fi
if [ -v KERNEL ]; then
	FLASH_KERNEL="flash write_image erase ${KERNEL_PATH}/arch/arm/boot/xipImage 0x08008000"
fi

if [ -v BOOTLOADER ]; then
	echo bootloader will be flashed
	echo bootloader file: ${BOOTLOADER_FILE}
fi
if [ -v DEVICETREE ]; then
	echo dtb will be flashed
	echo dtb path: ${DEVICETREE_PATH}
fi
if [ -v KERNEL ]; then
	echo kernel will be flashed
	echo kernel path: ${KERNEL_PATH}
fi

openocd -f board/stm32f429disc1.cfg -c "init" -c "reset init" -c "flash probe 0" -c "flash info 0" \
	-c "${FLASH_BOOTLOADER}" -c "${FLASH_DEVICETREE}" -c "${FLASH_KERNEL}" \
	-c "reset run" -c "shutdown"


# FLASH_INFO="flash info 0"
# echo ${FLASH_INFO}
# openocd -f board/stm32f429disc1.cfg -c "init" -c "reset init" -c "flash probe 0" -c "${FLASH_INFO}" -c "reset run" -c "shutdown"
