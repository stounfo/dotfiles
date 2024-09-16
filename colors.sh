#!/bin/bash

# Loop through ANSI color codes (0-7 for dim colors)
for color in {0..7}; do
  # Regular color
  echo -e "\e[3${color}mRegular Color ${color}\e[0m"
  # Bright color
  echo -e "\e[9${color}mBright Color ${color}\e[0m"
  # Dimmed color
  echo -e "\e[2;3${color}mDimmed Color ${color}\e[0m"
done
