#!/bin/bash

# xinput - displays pointers/keyboards
# xrandr - shows screen names
input1=$(xinput | grep wch.cn | head -1 | cut -f2 | cut -d'=' -f2)
input2=$(xinput | grep wch.cn | tail -1 | cut -f2 | cut -d'=' -f2)
screen1=$(xrandr | grep connected | head -1 | cut -f1)
screen2=$(xrandr | grep connected | tail -1 | cut -f1)

xinput map-to-output $input1 $screen1
xinput map-to-output $input2 $screen2
