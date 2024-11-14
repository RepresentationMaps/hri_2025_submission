FROM ros:humble

RUN groupadd -r user && \
    useradd -r -g user -m -d /home/user -s /bin/bash user


RUN echo "source /opt/ros/humble/setup.bash" >> /home/user/.bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc 

RUN mkdir -p /home/user/ws/src && chown -R user:user /home/user/ws

# USER user

WORKDIR /home/user/ws

COPY --chown=user:user ./src /home/user/ws/src

RUN apt update
RUN rosdep update
RUN rosdep install -y --from-paths src/simulation_player
RUN bash -c "source /opt/ros/humble/setup.bash && colcon build --packages-select simulation_player"

RUN rosdep install -y --skip-keys map_handler --skip-keys representation_plugin_base --skip-keys vdb2pc --skip-keys OpenCV --skip-keys openvdb --skip-keys reg_of_space_server --skip-keys representation_plugins --from-path src

RUN apt install -y libboost-iostreams-dev libtbb-dev libblosc-dev

RUN bash -c "source /opt/ros/humble/setup.bash && colcon build --packages-select reg_of_space_server"

COPY --chown=user:user ./openvdb /home/user/ws/openvdb

RUN cd openvdb && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j4 && \
    make install

RUN apt install -y libopencv-dev

RUN bash -c "source /opt/ros/humble/setup.bash && colcon build --packages-select colcon build --packages-select vdb2pc reg_of_space_server representation_plugin_base map_handler representation_plugins representation_manager simulation_player --cmake-args "-DFIND_OPENVDB_PATH=/usr/local/lib/cmake/OpenVDB""

RUN apt install -y ros-humble-rviz2

RUN mkdir -p /home/user/ws/rviz && chown -R user:user /home/user/ws/rviz
COPY --chown=user:user ./hri_2025.rviz /home/user/ws/rviz
COPY --chown=user:user ./run_simulation.sh /home/user/ws

ENV ROS_DOMAIN_ID=10

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /home/user/ws/install/setup.bash" >> ~/.bashrc

CMD ["bash", "-c", "source /opt/ros/humble/setup.bash && exec bash"]
