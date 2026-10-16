# ROM REPO INIT
# =========================

repo init --no-repo-verify --git-lfs \
  -u https://github.com/LineageOS/android.git \
  -b lineage-20.0 \
  -g default,-mips,-darwin,-notdefault

echo "-----------------------------"
echo "Repo init completed"
echo "-----------------------------"

# =========================
# SOURCE SYNC
# =========================

echo "Starting source sync..."

/opt/crave/resync.sh
/opt/crave/resync.sh
/opt/crave/resync.sh

echo "Source sync completed"

# =========================
# DEVICE TREE + VENDOR
# =========================

git clone https://github.com/codebht/Android_device_t482l.git \
  -b main device/acer/AcerOne8T482L

git clone https://github.com/codebht/android_vendor_T482L.git \
  -b main vendor/acer/AcerOne8T482L

# =========================
# BUILD ENVIRONMENT
# =========================

. build/envsetup.sh

# =========================
# LUNCH
# =========================

lunch lineage_AcerOne8T482L-userdebug

# =========================
# BUILD ROM
# =========================

m bacon

echo "-----------------------------"
echo "ROM build completed"
echo "-----------------------------"

# =========================
# GOFILE AUTO UPLOAD
# =========================

PRODUCT="AcerOne8T482L"
OUT_DIR="out/target/product/${PRODUCT}"

echo "Searching for ROM ZIP..."

ZIP="$(find "$OUT_DIR" -maxdepth 1 -type f \
  -name '*.zip' -size +0c \
  ! -name '*symbols*' \
  -printf '%T@ %p\n' 2>/dev/null |
  sort -nr | head -n 1 | cut -d' ' -f2-)"

if [ -z "$ZIP" ] || [ ! -f "$ZIP" ]; then
    echo "ERROR: No ROM ZIP found in $OUT_DIR"
    echo "Build may have completed without producing a flashable ZIP."
    exit 1
fi

echo "ROM found: $ZIP"
ls -lh "$ZIP"

# Install/check uploader dependencies
if ! command -v curl >/dev/null 2>&1 ||
   ! command -v jq >/dev/null 2>&1; then
    echo "WARNING: curl and/or jq is missing."
    echo "Install them before uploading."
    exit 0
fi

# Download GoFile uploader
UPLOADER="/tmp/gofile-upload.sh"

if ! curl -fL --retry 3 \
  "https://raw.githubusercontent.com/THE-EGO-999-GT/GoFile-Upload/master/upload.sh" \
  -o "$UPLOADER"; then
    echo "WARNING: Could not download GoFile uploader."
    exit 0
fi

chmod +x "$UPLOADER"

# Upload ROM
echo "Starting GoFile upload..."

if bash "$UPLOADER" "$ZIP"; then
    echo "GoFile uploader finished."
else
    echo "WARNING: GoFile upload failed."
    echo "ROM ZIP remains at: $ZIP"
fi

echo "-----------------------------"
echo "BUILD SCRIPT FINISHED"
echo "-----------------------------"
