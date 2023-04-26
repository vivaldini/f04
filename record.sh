#!/bin/bash

path="/home/\$(optenv USER mrs)/bag_files/kelen/"

# By default, we record everything.
# Except for this list of EXCLUDED topics:
exclude=(

# IN GENERAL, DON'T RECORD CAMERAS
#
# If you want to record cameras, create a copy of this script
# and place it at your tmux session.
#
# Please, seek an advice of a senior researcher of MRS about
# what can be recorded. Recording too much data can lead to
# ROS communication hiccups, which can lead to eland, failsafe
# or just a CRASH.

# Every topic containing "compressed"

# Bluefox "image_raw"



# Realsense d435
'(.*)compressedDepth(.*)'
'(.*)/down_rgbd/depth/camera_info(.*)'
'(.*)/down_rgbd/depth/image_raw(.*)'
'(.*)/down_rgbd/extrinsics/depth_to_color(.*)'
'(.*)/down_rgbd/rgb_camera/auto_exposure_roi/parameter_descriptions(.*)'
'(.*)/down_rgbd/rgb_camera/auto_exposure_roi/parameter_updates(.*)'
'(.*)/down_rgbd/stereo_module/auto_exposure_roi/parameter_descriptions(.*)'
'(.*)/down_rgbd/stereo_module/auto_exposure_roi/parameter_updates(.*)'
'(.*)/down_rgbd/aligned_depth_to_color/image_raw(.*)'
'(.*)/down_rgbd/aligned_depth_to_color/image_raw(.*)'
'(.*)/down_rgbd/color/image_raw(.*)'
'(.*)/down_rgbd/color/image_raw/compressed/parameter_descriptions(.*)'
'(.*)/down_rgbd/color/image_raw/compressed/parameter_updates(.*)'
'(.*)/down_rgbd/aligned_depth_to_color/image_raw(.*)'


)
# file's header
filename=`mktemp`
echo "<launch>" > "$filename"
echo "<arg name=\"UAV_NAME\" default=\"\$(env UAV_NAME)\" />" >> "$filename"
echo "<group ns=\"\$(arg UAV_NAME)\">" >> "$filename"

echo -n "<node pkg=\"mrs_uav_general\" type=\"mrs_record\" name=\"mrs_rosbag_record\" output=\"screen\" args=\"-o $path -a" >> "$filename"

# if there is anything to exclude
if [ "${#exclude[*]}" -gt 0 ]; then

  echo -n " -x " >> "$filename"

  # list all the string and separate the with |
  for ((i=0; i < ${#exclude[*]}; i++));
  do
    echo -n "${exclude[$i]}" >> "$filename"
    if [ "$i" -lt "$( expr ${#exclude[*]} - 1)" ]; then
      echo -n "|" >> "$filename"
    fi
  done

fi

echo "\">" >> "$filename"

echo "<remap from=\"~status_msg_out\" to=\"mrs_uav_status/display_string\" />" >> "$filename"
echo "<remap from=\"~data_rate_out\" to=\"~data_rate_MB_per_s\" />" >> "$filename"

# file's footer
echo "</node>" >> "$filename"
echo "</group>" >> "$filename"
echo "</launch>" >> "$filename"

cat $filename
roslaunch $filename

