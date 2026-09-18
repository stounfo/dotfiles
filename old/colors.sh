#!/bin/bash

# Loop through ANSI color codes (0-7 for dim colors)
for color in {0..7}; do
  # Regular color
  echo -e "\033[3${color}mRegular Color ${color}\033[0m"
  # Bright color
  echo -e "\033[9${color}mBright Color ${color}\033[0m"
  # Dimmed color
  echo -e "\033[2;3${color}mDimmed Color ${color}\033[0m"
done
