#!/bin/bash
max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
sensitivity=$((max/10))
min=$((max/10))
delay=6
while [ 1 ]
do
updated=1
while [ $updated -gt 0 ]
do
updated=0
backlight=$(cat /sys/class/backlight/intel_backlight/brightness)
sensor=$(cat /sys/bus/iio/devices/iio:device0/subsystem/devices/iio:device2/in_illuminance_raw)
target=$sensor
if [ $backlight -gt $sensor ]
then
if [ $(($backlight - $sensor)) -gt $sensitivity ]
then
updated=1
fi
fi
if [ $backlight -lt $sensor ]
then
if [ $(($sensor - $backlight)) -gt $sensitivity ]
then
updated=1
fi
fi
if [ $target -gt $max ]
then
target=$max
fi
if [ $target -lt 1 ]
then
target=$min
fi
if [ $updated -gt 0 ]
then
echo "Starting brightness: $backlight"
echo "Ambient light: $sensor"
echo "Adjusted brightness: $target"
echo "-------------------------------"
echo "Sensitivity: $sensitivity"
echo "Min: $min Max: $max"
echo
echo $target > /sys/class/backlight/intel_backlight/brightness
fi
done
sleep $delay
done
