battery_percentage=$(pmset -g batt | grep -o '[0-9]*%' | sed 's/%//')
echo "$battery_percentage%"
