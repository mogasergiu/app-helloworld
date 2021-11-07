#!/bin/bash

if test $# -ne 1; then
    echo "Usage: $0 <kvm_image>" 1>&2
    exit 1
fi

kvm_image="$1"
sudo qemu-system-x86_64 -hda "$kvm_image" -d int --no-reboot
