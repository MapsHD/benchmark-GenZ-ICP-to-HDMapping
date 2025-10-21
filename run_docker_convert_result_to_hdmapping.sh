#!/bin/bash

for SEQUENCE in {1..5}; do
    RESULTS_PATH=./data/ConSLAM/sequence${SEQUENCE}/results-genz-icp/
    echo "--- Processing sequence ${SEQUENCE} ---"
    LATEST_ROSBAG2_FOLDER=$(ls -dt ${RESULTS_PATH}/rosbag2_* 2>/dev/null | head -n 1)
    echo "Latest rosbag2 folder: ${LATEST_ROSBAG2_FOLDER}"
    
    # Check if folder exists
    if [ -z "${LATEST_ROSBAG2_FOLDER}" ]; then
        echo "No rosbag2 folders found in ${RESULTS_PATH}"
        continue
    fi
    
    # Convert host path to container path
    CONTAINER_ROSBAG2_FOLDER=${LATEST_ROSBAG2_FOLDER/.\/data/\/data}
    
    # Run the docker command with the parameterized path
    echo "docker run --rm -it -v $(pwd)/data:/data genzicp2hdmapping:latest bash -c \"source /test_ws/src/install/setup.sh && ros2 run genz-icp-to-hdmapping listener ${CONTAINER_ROSBAG2_FOLDER}/*.mcap ${CONTAINER_ROSBAG2_FOLDER}/hdmapping\""
    docker run --rm -it -v $(pwd)/data:/data genzicp2hdmapping:latest bash -c "source /test_ws/src/install/setup.sh && rm -rf \"${LATEST_ROSBAG2_FOLDER}/hdmapping\" && mkdir \"${LATEST_ROSBAG2_FOLDER}/hdmapping\" && ros2 run genz-icp-to-hdmapping listener ${CONTAINER_ROSBAG2_FOLDER}/*.mcap ${CONTAINER_ROSBAG2_FOLDER}/hdmapping"
    echo "--- Processed sequence ${SEQUENCE} ---"
done
