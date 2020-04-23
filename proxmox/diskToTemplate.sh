#!/bin/bash

usage(){
echo " -h|-s -n (-i -w)"
echo "-h                  help"
echo "-s          sourcefile(http ou local)"
echo "-n            vm name"
echo "-w   is the vm a windows one"
echo "-i             vmid of the created vm(>0)"
echo "-c          add-cloudinitdisk"
echo "-t        new vm has a template"
}


WIN="0"
SOURCE=""
NAME=""
HELP="0"
CLOUDINIT="0"
TEMPLATE="0"

VMSTORAGE="local-zfs"

VMID="${RANDOM:0:4}"

while getopts "hwcts:n:i:" OPTION; do
    case "${OPTION}"
    in
        h)          HELP="1";;
        s)          SOURCE=${OPTARG};;
        n)          NAME=${OPTARG};;
        i)          VMID=${OPTARG};;
        w)          WIN="1";;
        c)          CLOUDINIT="1";;
        t)          TEMPLATE="1";;
        ?)          usage >&2
                    exit 1;;
    esac
done

if [[ $HELP == "1" ]]; then
    usage
    exit 0
fi
if [[ ${VMID} == "0" ]]; then
    echo "Invalid VMID"
    usage
    exit 0
fi

if [[ $NAME == "" ]] || [[ $SOURCE = *_* ]]; then
    echo "Invalid name:$NAME"
    usage
    exit 0
fi

if [[ $SOURCE = ^http* ]];then
    curl -L $SOURCE -o /tmp/${VMID}
    SOURCEFILE="/tmp/${VMID}"
else
    SOURCEFILE="$SOURCE"
    if [[ $SOURCEFILE != *".qcow2" ]]; then
        echo "FIle source must end by .qcow2"
        exit 1
    fi
fi

FORMAT=$(qemu-img info $SOURCEFILE | egrep -o '^file format: .*$' | sed 's/file format: //g')
if [[ "$FORMAT" != "qcow2"  ]]; then
    echo "Invalid format image: $FORMAT"
    usage
    exit 1
fi

qm create ${VMID} --memory 4096 --name $NAME --net0 virtio,bridge=vmbr0 --boot c --bootdisk scsi0

if [[ $? == "1" ]]; then
    echo "Error while creating VM vmid:${VMID}"
    exit 1
fi

qm importdisk ${VMID} $SOURCEFILE ${VMSTORAGE} --format=qcow2

if [[ $? == "1" ]]; then
    echo "Error while importing disk"
    exit 1
fi

qm set ${VMID} --scsihw virtio-scsi-pci --scsi0 ${VMSTORAGE}:vm-${VMID}-disk-0

if [[ $? == "1" ]]; then
    echo "Error while setting disk to the vm:${VMID}"
    exit 1
fi

if [[ $CLOUDINIT == "1" ]]; then
    qm set ${VMID} --ide2 ${VMSTORAGE}:cloudinit --serial0 socket --vga serial0
    echo "Adding cloudinit disk to vm $NAME"
fi

if [[ $TEMPLATE == "1" ]]; then
    qm template ${VMID}
    echo "VM $NAME convert to template"
fi