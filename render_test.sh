#!/bin/bash

# Test render performance

# Set the number of lines to print
LINES=1000

# Set the string to print
STRING="The quick brown fox jumps over the lazy dog."

# Start the timer
START_TIME=$(date +%s.%N)

# Print the lines
for i in $(seq 1 $LINES); do
  # Print the string with a random color
  echo -e "\e[38;2;$((RANDOM % 256));$((RANDOM % 256));$((RANDOM % 256))m$STRING\e[0m"
done

# Stop the timer
END_TIME=$(date +%s.%N)

# Calculate the elapsed time
ELAPSED_TIME=$(awk -v start=$START_TIME -v end=$END_TIME 'BEGIN {print end - start}')

# Print the elapsed time
echo "Elapsed time: $ELAPSED_TIME seconds"
