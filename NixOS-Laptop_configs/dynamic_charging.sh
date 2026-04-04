#!/run/current-system/sw/bin/zsh
BAT="/sys/class/power_supply/BAT0"
TEMP=$(cat $BAT/temp)
TEMP_C=$((TEMP / 10))

if [ "$TEMP_C" -lt 35 ]; then
    # battery cool, allow full charge
    echo 100 > $BAT/charge_control_end_threshold
    echo 95  > $BAT/charge_control_start_threshold
else
    # battery hot, limit to 85%
    echo 85  > $BAT/charge_control_end_threshold
    echo 84  > $BAT/charge_control_start_threshold
fi

