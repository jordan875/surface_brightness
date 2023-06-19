#!/bin/bash

LevelSteps=120
AnimationDelay=0.032
MaxScreenBrightness=7500
SensorDelay=5

MinimumBrightness=75

SensorToDisplayScale=24

while true; do
    Light=$(cat /sys/bus/iio/devices/iio\:device?/in_illuminance_raw)

    CurrentBrightness=$(cat /sys/class/backlight/intel_backlight/brightness)

    Light=$(( $Light + $MinimumBrightness ))

    TempLight=$(($Light * $SensorToDisplayScale))

    if [[ $TempLight -gt $MaxScreenBrightness ]]
    then
        NewLight=$MaxScreenBrightness
    else
        NewLight=$TempLight
    fi

    DiffCount=$(( ($NewLight - $CurrentBrightness)/$LevelSteps ))

    for i in $(eval echo {1..$LevelSteps} )
    do
        if [[ $DiffCount -lt 0 ]]
        then
            NewBrightnessChange=$( echo "$DiffCount" | awk -F "-" {'print$2'})
            NewBrightnessChange=$(echo $NewBrightnessChange-)
        else
            NewBrightnessChange=$(echo +$DiffCount)
        fi

        brightnessctl -q s $NewBrightnessChange
        sleep $AnimationDelay
    done

    sleep $SensorDelay
done
