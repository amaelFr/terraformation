#!/bin/bash

usage(){
echo " -h|-s -n (-i -w)"
echo "-h                    help"
echo "-s                    sourcefile(http ou local)"
echo "-n                    vm name"
echo "-w                    is the vm a windows one"
echo "-i                    vmid of the created vm(>0)"
echo "-c                    add-cloudinitdisk"
echo "-t                    new vm has a template"
echo "-v                    vga serial (like cloud image)"
}


SOURCE=""
NAME=""
HELP="0"
CLOUDINIT="0"
TEMPLATE="0"
VGA="0"
WIN="0"


# while getopts "hvcts:n:i:" OPTION; do
while getopts "hs:n:" OPTION; do
    case "${OPTION}"
    in
        h)          HELP="1";;
        s)          SOURCE=${OPTARG};;
        n)          NAME=${OPTARG};;
        # i)          VMID=${OPTARG};;
        # w)          WIN="1";;
        # v)          VGA="1";;
        # c)          CLOUDINIT="1";;
        # t)          TEMPLATE="1";;
        ?)          usage >&2
                    exit 1;;
    esac
done

if [[ $HELP == "1" ]]; then
    usage
    exit 0
fi

if [[ $NAME == "" ]] || [[ $SOURCE = *_* ]]; then
    echo "Invalid name:$NAME"
    usage
    exit 0
fi


echo "$SOURCE"

if [[ $SOURCE =~ ^http* ]];then
    curl -L $SOURCE -o /tmp/${NAME}.qcow2
    SOURCEFILE="/tmp/${NAME}.qcow2"
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

openstack image create --disk-format qcow2 --container-format bare --public --file $SOURCEFILE $NAME