#!/bin/bash

LevelSteps=120
AnimationDelay=0.032
MaxScreenBrightness=7500
SensorDelay=5

MinimumBrightness=050

SensorToDisplayScale=24

while true; do
    # Check the first path
    if [[ -f /sys/bus/iio/devices/iio\:device0/in_illuminance_raw ]]; then
        Light=$(cat /sys/bus/iio/devices/iio\:device0/in_illuminance_raw)
    # If the first path is not available, check the second one
    elif [[ -f /sys/bus/iio/devices/iio\:device0/subsystem/devices/iio:device2/in_illuminance_raw ]]; then
        Light=$(cat /sys/bus/iio/devices/iio\:device0/subsystem/devices/iio:device2/in_illuminance_raw)
    # If neither path is available, handle the error as appropriate
    else
        echo "Sensor not found" >&2
        exit 1
    fi

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
