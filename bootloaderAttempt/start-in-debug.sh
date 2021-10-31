#!/bin/bash

if test $# -ne 1; then
    echo "Usage: $0 <kvm_image>" 1>&2
    exit 1
fi

kvm_image="$1"
#qemu_script="/bin/qemu-guest"
qemu_script="qemu-system-x86_64"
debug_port="1234"

"$qemu_script" -hda "$kvm_image" -s -S -enable-kvm
