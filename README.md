# GenZ-ICP to HDMapping simplified instruction

## Step 1 (prepare data)
Download the dataset `reg-1.bag` by clicking [link](https://cloud.cylab.be/public.php/dav/files/7PgyjbM2CBcakN5/reg-1.bag) (it is part of [Bunker DVI Dataset](https://charleshamesse.github.io/bunker-dvi-dataset)) and convert with [tool](https://github.com/MapsHD/livox_bag_aggregate) to 'reg-1.bag-pc.bag'.

File 'reg-1.bag-pc.bag' is an input for further calculations.
It should be located in '~/hdmapping-benchmark/data'.

## Step 2 (prepare docker)
Run following commands in terminal

```shell
mkdir -p ~/hdmapping-benchmark
cd ~/hdmapping-benchmark
git clone https://github.com/MapsHD/benchmark-GenZ-ICP-to-HDMapping.git --recursive
cd benchmark-GenZ-ICP-to-HDMapping
git checkout Bunker-DVI-Dataset-reg-1
docker build -t genz-icp_humble .
```

## Step 3 (Convert data)
We now convert data from ROS1 to ROS2

```shell
docker run -it -v ~/hdmapping-benchmark/data:/data --user 1000:1000 genz-icp_humble /bin/bash
cd /data
rosbags-convert --src reg-1.bag-pc.bag --dst reg-1-ros2 
```

close terminal

## Step 4 (run docker, file 'reg-1-ros2' should be in '~/hdmapping-benchmark/data')
open new terminal

```shell
cd ~/hdmapping-benchmark/benchmark-GenZ-ICP-to-HDMapping
chmod +x docker_session_run-ros2-genz-icp.sh 
cd ~/hdmapping-benchmark/data
~/hdmapping-benchmark/benchmark-GenZ-ICP-to-HDMapping/docker_session_run-ros2-genz-icp.sh reg-1-ros2 .
```

## Step 5 (Open and visualize data)
Expected data should appear in ~/hdmapping-benchmark/data/output_hdmapping-genz
Use tool [multi_view_tls_registration_step_2](https://github.com/MapsHD/HDMapping) to open session.json from ~/hdmapping-benchmark/data/output_hdmapping-genz.

You should see following data

lio_initial_poses.reg

poses.reg

scan_lio_*.laz

session.json

trajectory_lio_*.csv

## Movie
[[movie]]()

## Contact email
januszbedkowski@gmail.com