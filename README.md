# [GENZ-ICP](https://github.com/cocel-postech/genz-icp) converter to [HDMapping](https://github.com/MapsHD/HDMapping)

## Hint

Please change branch to [Bunker-DVI-Dataset-reg-1](https://github.com/MapsHD/benchmark-GenZ-ICP-to-HDMapping/tree/Bunker-DVI-Dataset-reg-1) for quick experiment.  

## Intended use 

This small toolset allows to integrate SLAM solution provided by [genz-icp](https://github.com/cocel-postech/genz-icp) with [HDMapping](https://github.com/MapsHD/HDMapping).
This repository contains ROS 2 workspace that :
  - submodule to tested revision of GenZ ICP 
  - a converter that listens to topics advertised from odometry node and save data in format compatible with HDMapping.

## Dependencies

```shell
sudo apt install -y nlohmann-json3-dev
```

## Building

Clone the repo
```shell
mkdir -p /test_ws/src
cd /test_ws/src
git clone https://github.com/marcinmatecki/GenZ-ICP-to-HDMapping.git --recursive
cd ..
colcon build
```

## Usage - data SLAM:

Prepare recorded bag with estimated odometry:

In first terminal record bag:
```shell
ros2 bag record /genz/local_map /genz/odometry
```

 start odometry:
```shell 
cd /test_ws/
source ./install/setup.sh # adjust to used shell
ros2 launch genz_icp odometry.launch.py topic:=<topic_name>
ros2 bag play <rosbag_file_name>.db3
```

## Usage - conversion:

```shell
cd /test_ws/
source ./install/setup.sh # adjust to used shell
ros2 run genz-icp-to-hdmapping listener <recorded_bag> <output_dir>
```

## Example:

Download the dataset from [NTU-VIRAL](https://ntu-aris.github.io/ntu_viral_dataset/)
For this example, download eee_03.

## Convert(If it's a ROS1 .bag file):

```shell
rosbags-convert --src {your_downloaded_bag} --dst {desired_destination_for_the_converted_bag}
```

## Record the bag file:

```shell
ros2 bag record /genz/local_map /genz/odometry -o {your_directory_for_the_recorded_bag}
```

## GenZ Launch:

```shell
cd /test_ws/
source ./install/setup.sh # adjust to used shell
ros2 launch genz_icp odometry.launch.py topic:=/os1_cloud_node1/points
ros2 bag play <rosbag_file_name>.db3
```

## During the record (if you want to stop recording earlier) / after finishing the bag:

```shell
In the terminal where the ros record is, interrupt the recording by CTRL+C
Do it also in ros launch terminal by CTRL+C.
```

## Usage - Conversion (ROS bag to HDMapping, after recording stops):

```shell
cd /test_ws/
source ./install/setup.sh # adjust to used shell
ros2 run genz-icp-to-hdmapping listener <recorded_bag> <output_dir>
```

## Running with Docker

To run the complete pipeline using Docker:

### 1. Build the Docker image:

```shell
./build-docker.sh
```

### 2. Convert ROS1 bags to ROS2 format (if needed):

```shell
./run_docker_convert_to_ros2.sh
```

Note: Only run this step if your dataset contains ROS1 `.bag` files that need to be converted to ROS2 format.

After conversion:

```
data
└── ConSLAM
    ├── sequence1
    │   ├── converted
    │   │   ├── converted.db3
    │   │   └── metadata.yaml
    │   ├── Copy of recording.bag
    ├── sequence2
    │   ├── converted
    │   │   ├── converted.db3
    │   │   └── metadata.yaml
    │   ├── Copy of recording.bag
```



### 3. Process all sequences:

```shell
./run_all_sequences.sh
```

This script runs the GenZ-ICP odometry processing for all sequences using Docker Compose.

### 4. Convert results to HDMapping format:

```shell
./run_docker_convert_result_to_hdmapping.sh
```

This script converts the recorded GenZ-ICP results to HDMapping-compatible format for all processed sequences.

### Results

```
data
└── ConSLAM
    ├── sequence1
    │   ├── converted
    │   │   ├── converted.db3
    │   │   └── metadata.yaml
    │   ├── Copy of recording.bag
    │   ├── results-genz-icp
    │   │   └── rosbag2_2025_10_20-21_08_46
    │   │       ├── hdmapping
    │   │       └── rosbag2_2025_10_20-21_08_46_0.mcap
    ├── sequence2
    │   ├── converted
    │   │   ├── converted.db3
    │   │   └── metadata.yaml
    │   ├── Copy of recording.bag
    │   ├── results-genz-icp
    │   │   └── rosbag2_2025_10_20-21_16_05
    │   │       ├── hdmapping
    │   │       └── rosbag2_2025_10_20-21_16_05_0.mcap
```

