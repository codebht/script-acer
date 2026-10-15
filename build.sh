# Rom repo init

repo init --no-repo-verify --git-lfs \
-u https://github.com/LineageOS/android.git \
-b lineage-20.0 \
-g default,-mips,-darwin,-notdefault

echo "-----------------------------"
echo "Repo init cloned successfully"
echo "-----------------------------"

# syncing

echo "-----------------------"
echo "Starting to sync source"
echo "-----------------------"

/opt/crave/resync.sh
/opt/crave/resync.sh
/opt/crave/resync.sh

echo "------------------------"
echo "Source syncing completed"
echo "------------------------"

# DT + Vendor

git clone https://github.com/codebht/Android_device_t482l.git \
-b main device/acer/AcerOne8T482L

git clone https://github.com/codebht/android_vendor_T482L.git \
-b main vendor/acer/AcerOne8T482L

echo "---------------------"
echo "Trees cloned successfully"
echo "---------------------"

# Build environment

. build/envsetup.sh

echo "---------------------------"
echo "Build/envsetup.sh completed"
echo "---------------------------"

# Lunch

lunch lineage_AcerOne8T482L-userdebug

# Build ROM

m bacon

echo "----------"
echo "Done"
echo "----------"