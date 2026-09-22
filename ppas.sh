#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /media/raizel/Projetos/Lazarus_4_8/HorseTeste/project1
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2     -L. -o /media/raizel/Projetos/Lazarus_4_8/HorseTeste/project1 -T /media/raizel/Projetos/Lazarus_4_8/HorseTeste/link22335.res -e _start
if [ $? != 0 ]; then DoExitLink /media/raizel/Projetos/Lazarus_4_8/HorseTeste/project1; fi
IFS=$OFS
