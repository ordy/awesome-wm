#!/bin/bash
 
healthy='#8AE62E'
low='#E60000'
discharge='#dc322f'
 
capacity=`cat /sys/class/power_supply/BAT0/capacity`
if (($capacity <= 25));
then
        capacityColour=$low
else
        capacityColour=$healthy
fi
 
status=`cat /sys/class/power_supply/BAT0/status`
 
if [[ "$status" = "Discharging" ]]
then
        statusColour=$discharge
        status="▼"
else
        statusColour=$healthy
        status="▲"
fi
 
echo "<span color='$capacityColour'>$capacity%</span> <span color='$statusColour'>$status</span>"