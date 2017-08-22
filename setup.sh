#!/bin/bash

### 	***MUST*** be run from directory containing setup.sh file ###

for file in `grep -R __install_dir__ * | awk -F : '{print $1}' | grep -v setup`
do
	sed -i s,__install_dir__,`pwd`,g ${file}
done

chmod 775 dp* commons/* MODULES/*
