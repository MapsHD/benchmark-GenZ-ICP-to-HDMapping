#!/bin/bash

# run_benchmark.sh - Reusable benchmark runner for GenZ-ICP
# Usage: ./run_benchmark.sh <config_name> <input_bag_directory> [compose_file]
#
# Examples:
#   ./run_benchmark.sh avia /path/to/data/Pipes/AVIA/ros2bag/mandeye_bag/
#   ./run_benchmark.sh conslam /path/to/data/ConSLAM/sequence1/converted/
#   From main repo: ./methods/benchmark-GenZ-ICP-to-HDMapping/run_benchmark.sh avia /path/to/data/

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
CONFIG_NAME="${1:-}"
INPUT_BAG_DIRECTORY="${2:-}"
COMPOSE_FILE="${3:-docker-compose.yml}"

# Function to show usage
usage() {
    echo "Usage: $0 <config_name> <input_bag_directory> [compose_file]"
    echo ""
    echo "Arguments:"
    echo "  config_name          Name of config file in configs/ (e.g., 'avia', 'conslam')"
    echo "  input_bag_directory  Path to ROS2 bag directory"
    echo "  compose_file         Docker compose file (default: docker-compose.yml)"
    echo ""
    echo "Examples:"
    echo "  $0 avia /path/to/data/Pipes/AVIA/ros2bag/mandeye_bag/"
    echo "  $0 conslam /path/to/data/ConSLAM/sequence1/converted/"
    echo ""
    echo "Available configs:"
    ls -1 "${SCRIPT_DIR}/configs/" 2>/dev/null | grep "\.env$" | sed 's/\.env$/  - /' || echo "  (none)"
    exit 1
}

# Validate arguments
if [ -z "$CONFIG_NAME" ] || [ -z "$INPUT_BAG_DIRECTORY" ]; then
    usage
fi

# Check if config file exists
CONFIG_FILE="${SCRIPT_DIR}/configs/${CONFIG_NAME}.env"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    echo ""
    echo "Available configs:"
    ls -1 "${SCRIPT_DIR}/configs/" 2>/dev/null | grep "\.env$" | sed 's/\.env$//' | sed 's/^/  - /' || echo "  (none)"
    exit 1
fi

# Check if input directory exists
if [ ! -d "$INPUT_BAG_DIRECTORY" ]; then
    echo "Error: Input directory not found: $INPUT_BAG_DIRECTORY"
    exit 1
fi

# Load config and export variables
# Note: set -a makes all variables automatically exported when set
# Docker Compose will inherit these environment variables from this shell
echo "Loading config: $CONFIG_FILE"
set -a  # Enable auto-export mode
source "$CONFIG_FILE"  # Variables from config are now exported
set +a  # Disable auto-export mode

# Export INPUT_BAG_DIRECTORY with absolute path
# (Variables from config file are already exported from the set -a block above)
export INPUT_BAG_DIRECTORY="$(realpath "$INPUT_BAG_DIRECTORY")"

echo "=========================================="
echo "Running GenZ-ICP benchmark"
echo "Config: $CONFIG_NAME"
echo "Input directory: $INPUT_BAG_DIRECTORY"
echo "Input topic: $INPUT_TOPIC"
echo "Output directory: $OUTPUT_DIR"
echo "=========================================="

# Change to script directory for docker compose
cd "$SCRIPT_DIR"

# Run docker compose
echo "Starting GenZ-ICP processing..."
docker compose -f "$COMPOSE_FILE" up

# Run conversion to hdmapping format
echo ""
echo "=========================================="
echo "Converting results to hdmapping format..."
echo "=========================================="
LATEST_ROSBAG2_FOLDER="${INPUT_BAG_DIRECTORY}/${OUTPUT_DIR}/"

if [ ! -d "$LATEST_ROSBAG2_FOLDER" ]; then
    echo "Error: Results folder not found: $LATEST_ROSBAG2_FOLDER"
    exit 1
fi

docker run --rm -it \
    -v "${LATEST_ROSBAG2_FOLDER}:/data" \
    ghcr.io/mapshd/genzicp2hdmapping:latest \
    bash -c "source /test_ws/src/install/setup.sh && rm -rf /data/hdmapping && ros2 run genz-icp-to-hdmapping listener /data/*.mcap /data/hdmapping"

echo ""
echo "=========================================="
echo "Benchmark completed successfully!"
echo "=========================================="
echo "Results location: ${LATEST_ROSBAG2_FOLDER}"
echo "  - ROS2 bag: ${LATEST_ROSBAG2_FOLDER}"
echo "  - HDMapping output: ${LATEST_ROSBAG2_FOLDER}/hdmapping"
echo "=========================================="

