#codebht
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
echo "Acer trees cloned"
echo "---------------------"

# Local manifest
# Add this only if your repositories require additional projects.

mkdir -p .repo/local_manifests

cat > .repo/local_manifests/acer.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <remote name="github" fetch="https://github.com/" />

    <project name="LineageOS/android_device_mediatek_sepolicy_vndr"
             path="device/mediatek/sepolicy_vndr"
             remote="github"
             revision="lineage-20.0" />

    <project name="LineageOS/android_hardware_mediatek"
             path="hardware/mediatek"
             remote="github"
             revision="lineage-20.0" />
</manifest>
EOF

# Sync additional manifest projects
/opt/crave/resync.sh

echo "---------------------"
echo "Tree setup completed"
echo "---------------------"

# build env

. b*/e*

echo "---------------------------"
echo "Build/envsetup.sh completed"
echo "---------------------------"

# signing script
# Configure private signing keys separately if required.

echo "----------------------------"
echo "Signing configuration checked"
echo "----------------------------"

# boss

lunch lineage_AcerOne8T482L-userdebug

m bacon

echo "----------"
echo "Done"
echo "----------"
