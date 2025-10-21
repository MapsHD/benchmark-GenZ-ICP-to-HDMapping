#!/bin/bash

# Simple script to run all sequences sequentially
# Usage: ./run_all_sequences.sh

set -e

echo "Running all sequences (1-5) sequentially..."

for i in {1..5}; do
    echo "=========================================="
    echo "Running sequence $i..."
    echo "=========================================="
    
    SEQUENCE_NUM=$i docker compose up
    
    echo "Sequence $i completed."
    echo ""
done

echo "All sequences completed!"
