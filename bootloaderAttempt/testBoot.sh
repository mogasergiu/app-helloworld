#!/bin/bash

rm -rf attempt
nasm -fbin bootloader.asm -o boot
dd if=boot >> attempt
dd if=../build/app-helloworld-both_kvm-x86_64.dbg >> attempt

