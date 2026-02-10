#!/bin/bash

IMAGE_NAME='genz-icp_humble'
TMUX_SESSION='ros2_session'

DATASET_CONTAINER_PATH='/ros2_ws/dataset'
BAG_OUTPUT_CONTAINER='/ros2_ws/recordings'

RECORDED_BAG_NAME="recorded-genz-icp"
HDMAPPING_OUT_NAME="output_hdmapping"

TOPIC='/livox/pointcloud'

usage() {
  echo "Usage:"
  echo "  $0 <input_bag_dir> <output_dir>"
  echo
  echo "If no arguments are provided, a GUI file selector will be used."
  exit 1
}

echo "=== GENZ-ICP ROS2 rosbag pipeline ==="

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

if [[ $# -eq 2 ]]; then
  DATASET_HOST_PATH="$1"
  BAG_OUTPUT_HOST="$2"
elif [[ $# -eq 0 ]]; then
  command -v zenity >/dev/null || {
    echo "Error: zenity is not available"
    exit 1
  }
  DATASET_HOST_PATH=$(zenity --file-selection --directory --title="Select BAG directory")
  BAG_OUTPUT_HOST=$(zenity --file-selection --directory --title="Select output directory")
else
  usage
fi

if [[ -z "$DATASET_HOST_PATH" || -z "$BAG_OUTPUT_HOST" ]]; then
  echo "Error: no file or directory selected"
  exit 1
fi

if [[ ! -d "$DATASET_HOST_PATH" ]]; then
  echo "Error: BAG directory does not exist: $DATASET_HOST_PATH"
  exit 1
fi

mkdir -p "$BAG_OUTPUT_HOST"

DATASET_HOST_PATH=$(realpath "$DATASET_HOST_PATH")
BAG_OUTPUT_HOST=$(realpath "$BAG_OUTPUT_HOST")

echo "Input bag dir : $DATASET_HOST_PATH"
echo "Output dir    : $BAG_OUTPUT_HOST"

xhost +local:docker >/dev/null

docker run -it --rm \
  --network host \
  -e DISPLAY=$DISPLAY \
  -e ROS_HOME=/tmp/.ros \
  -u 1000:1000 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$DATASET_HOST_PATH":"$DATASET_CONTAINER_PATH":ro \
  -v "$BAG_OUTPUT_HOST":"$BAG_OUTPUT_CONTAINER" \
  "$IMAGE_NAME" \
  /bin/bash -c '

    tmux new-session -d -s '"$TMUX_SESSION"'

    # ---------- PANEL 1: ROS2 launch ----------
    tmux send-keys -t '"$TMUX_SESSION"' '\''sleep 5
source /opt/ros/humble/setup.bash
source /ros2_ws/install/setup.bash
ros2 launch genz_icp odometry.launch.py topic:='"$TOPIC"'
'\'' C-m

    # ---------- PANEL 2: rosbag record ----------
    tmux split-window -v -t '"$TMUX_SESSION"'
    tmux send-keys -t '"$TMUX_SESSION"' '\''sleep 2
source /opt/ros/humble/setup.bash
source /ros2_ws/install/setup.bash

echo "[record] start"
ros2 bag record /genz/frame /genz/odometry \
  -o '"$BAG_OUTPUT_CONTAINER/$RECORDED_BAG_NAME"' --storage sqlite3

echo "[record] exit"
'\'' C-m

    # ---------- PANEL 3: rosbag play ----------
    tmux split-window -h -t '"$TMUX_SESSION"'
    tmux send-keys -t '"$TMUX_SESSION"' '\''sleep 5
source /opt/ros/humble/setup.bash
source /ros2_ws/install/setup.bash

echo "[play] start"
ros2 bag play '"$DATASET_CONTAINER_PATH"' --clock; tmux wait-for -S BAG_DONE;
echo "[play] done"
'\'' C-m

    # ---------- PANEL 4: controller ----------
    tmux new-window -t '"$TMUX_SESSION"' -n control '\''
source /opt/ros/humble/setup.bash
source /ros2_ws/install/setup.bash

echo "[control] waiting for play to finish"
tmux wait-for BAG_DONE

echo "[control] stopping record"
tmux send-keys -t '"$TMUX_SESSION"'.1 C-c

sleep 5
pkill ros2

sleep 7
pkill -f ros2 || true
'\''

    tmux attach -t '"$TMUX_SESSION"'
  '

docker run -it --rm \
  --network host \
  -e DISPLAY="$DISPLAY" \
  -e ROS_HOME=/tmp/.ros \
  -u 1000:1000 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$BAG_OUTPUT_HOST":"$BAG_OUTPUT_CONTAINER" \
  "$IMAGE_NAME" \
  /bin/bash -c "
    source /opt/ros/humble/setup.bash
    source /ros2_ws/install/setup.bash
    ros2 run genz-icp-to-hdmapping listener \
      \"$BAG_OUTPUT_CONTAINER/$RECORDED_BAG_NAME\" \
      \"$BAG_OUTPUT_CONTAINER/$HDMAPPING_OUT_NAME-genz\"
  "

echo "=== DONE ==="
