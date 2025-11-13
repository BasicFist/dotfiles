#!/bin/bash

# Test scrollback performance

# Set the number of lines to print
LINES=20000

# Set the string to print
STRING="The quick brown fox jumps over the lazy dog."

# Start the timer
START_TIME=$(date +%s.%N)

# Print the lines
for i in $(seq 1 $LINES); do
  echo $STRING
done

# Stop the timer
END_TIME=$(date +%s.%N)

# Calculate the elapsed time
ELAPSED_TIME=$(awk -v start=$START_TIME -v end=$END_TIME 'BEGIN {print end - start}')

# Print the elapsed time
echo "Elapsed time: $ELAPSED_TIME seconds"
