# =========================
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

# Clear existing device and vendor folders to prevent path conflicts
rm -rf device/acer/AcerOne8T482L
rm -rf vendor/acer/AcerOne8T482L

git clone https://github.com/codebht/Android_device_t482l.git \
  -b main device/acer/AcerOne8T482L

git clone https://github.com/codebht/android_vendor_T482L.git \
  -b main vendor/acer/AcerOne8T482L

echo "Device and vendor trees cloned"

# Strip out ALL remaining illegal VINTF manifest file copies automatically before building
sed -i '/\/vintf\/manifest_/d' vendor/acer/AcerOne8T482L/T482L-vendor-blobs.mk

# 🟢 ADD THIS SECOND LINE RIGHT HERE to clear the core framework manifests:
sed -i '/\/etc\/vintf\//d' vendor/acer/AcerOne8T482L/T482L-vendor-blobs.mk

echo "All VINTF copy patches applied successfully"

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
echo "ROM build command completed"
echo "-----------------------------"

# =========================
# FIND ZIP AND IMG FILES
# =========================

PRODUCT="AcerOne8T482L"
OUT_DIR="out/target/product/${PRODUCT}"

echo "Searching for ZIP and IMG files..."

mapfile -d '' FILES < <(
  find "$OUT_DIR" -maxdepth 1 -type f \
    \( -iname '*.zip' -o -iname '*.img' \) \
    -size +0c -print0 2>/dev/null
)

if [ "${#FILES[@]}" -eq 0 ]; then
    echo "No ZIP or IMG files found in $OUT_DIR"
    echo "Skipping upload."
else
    echo "Found ${#FILES[@]} file(s):"
    printf ' - %s\n' "${FILES[@]}"

    # =========================
    # CLONE GOFILE UPLOADER
    # =========================

    UPLOADER_DIR="/tmp/GoFile-Upload"

    if [ -d "$UPLOADER_DIR/.git" ]; then
        git -C "$UPLOADER_DIR" pull --ff-only
    else
        git clone https://github.com/Sushrut1101/GoFile-Upload.git \
          "$UPLOADER_DIR"
    fi

    # =========================
    # PERMISSIONS + DEPENDENCIES
    # =========================

    chmod +x "$UPLOADER_DIR/upload.sh"

    if ! command -v curl >/dev/null 2>&1 ||
       ! command -v jq >/dev/null 2>&1; then
        echo "curl and jq are required for uploading."
        echo "Skipping upload; build output is preserved."
    else
        # =========================
        # UPLOAD EACH FILE
        # =========================

        for FILE in "${FILES[@]}"; do
            echo "-----------------------------"
            echo "Uploading: $FILE"
            ls -lh "$FILE"

            if bash "$UPLOADER_DIR/upload.sh" "$FILE"; then
                echo "Uploader finished for: $FILE"
            else
                echo "WARNING: Upload failed for: $FILE"
            fi
        done
    fi
fi

echo "-----------------------------"
echo "BUILD SCRIPT FINISHED"
echo "-----------------------------"
