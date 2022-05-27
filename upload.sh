#!/bin/bash

# Source Vars
source $CONFIG

#Change to Kernel dir
cd ~/work

FILENAME=$(echo $OUTPUT)

echo "Starting to upload kernel.zip"

# Upload to oshi.at
if [ -z "$TIMEOUT" ];then
    TIMEOUT=20160
fi

#Upload to WeTransfer
transfer wet $FILENAME > link.txt || { echo "ERROR: Failed to Upload the Build!" && exit 1; }

# Mirror to oshi.at
curl -T $FILENAME https://oshi.at/${FILENAME}/${OUTPUT} > mirror.txt || { echo "WARNING: Failed to Mirror the Build!"; }

DL_LINK=$(cat link.txt | grep Download | cut -d\  -f3)
MIRROR_LINK=$(cat mirror.txt | grep Download | cut -d\  -f1)

# Show the Download Link
echo "=============================================="
echo "Download Link: ${DL_LINK}" || { echo "ERROR: Failed to Upload the Build!"; }
echo "Mirror: ${MIRROR_LINK}" || { echo "WARNING: Failed to Mirror the Build!"; }
echo "=============================================="

if [ "$BUILD_ZIP_OUT_DIR" = "true" ]; then
echo "Zipping and uploading the whole out directory..."
cd ~/work/Kernel
zip -r out.zip out
transfer wet out.zip
fi

# Exit
exit 0
