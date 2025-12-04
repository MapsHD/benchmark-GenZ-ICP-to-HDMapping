#!/bin/bash

# Simple script to run all sequences sequentially
# Usage: ./run_all_sequences.sh

set -e

echo "Running all sequences (1-5) sequentially..."

for SEQUENCE_NUM in {1..5}; do
    echo "=========================================="
    echo "Running sequence $i..."
    export INPUT_BAG_DIRECTORY="./data/ConSLAM/sequence${SEQUENCE_NUM}/converted/"
    echo "INPUT_BAG_DIRECTORY: $INPUT_BAG_DIRECTORY"
    echo "=========================================="
    
    INPUT_BAG_DIRECTORY=$INPUT_BAG_DIRECTORY docker compose up
    
    echo "Sequence $i completed."
    echo ""
done

echo "All sequences completed!"
