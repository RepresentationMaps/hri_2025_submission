#!/bin/bash

source /opt/ros/humble/setup.bash
source ./install/setup.bash

run_node() {
    echo "Starting node: $1"
    ros2 run $1 $2 &
}

run_node reg_of_space_server reg_of_space_server_node
run_node representation_manager representation_manager_node

sleep 3

echo "Starting RViz2 with configuration file: my_config.rviz"
rviz2 -d /home/user/exchange/hri_2025.rviz

echo "Press [CTRL+C] to stop the nodes and exit."
wait
