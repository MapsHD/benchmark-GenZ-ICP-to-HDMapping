ARG ROS_DISTRO=jazzy
FROM ros:${ROS_DISTRO}-ros-base-noble

SHELL ["/bin/bash", "-lc"]

RUN apt update
RUN apt install -y nlohmann-json3-dev libpcl-dev python3-pip
RUN pip3 install rosbags --break-system-packages
RUN mkdir -p /test_ws/src
COPY src/ /test_ws/src
RUN cd /test_ws/src && source /opt/ros/${ROS_DISTRO}/setup.bash && rosdep update && rosdep install --from-paths src --ignore-src -r -y || true && source /opt/ros/${ROS_DISTRO}/setup.bash &&colcon build


