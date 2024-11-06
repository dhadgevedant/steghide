#!/bin/bash

# Directories
COVER_DIR="cover_files"         # Directory with pre-downloaded cover files
SECRET_DIR="secret_files"        # Directory with files to embed
OUTPUT_DIR="embedded_files"      # Output directory for embedded files
PASSWORD="pass"                  # Password for embedding

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No color

# Ensure required directories exist
mkdir -p "$COVER_DIR" "$SECRET_DIR" "$OUTPUT_DIR"

# Get list of all cover files in an array and initialize cover index
COVER_FILES=("$COVER_DIR"/*)  # All files in COVER_DIR
NUM_COVERS=${#COVER_FILES[@]}
COVER_INDEX=0

# Step 1: Iterate over each secret file
for SECRET_FILE in "$SECRET_DIR"/*; do
    # Get the file name and size of the secret file
    SECRET_FILENAME=$(basename "$SECRET_FILE")
    SECRET_FILESIZE=$(stat -c%s "$SECRET_FILE")  # File size in bytes
    
    echo "Processing $SECRET_FILENAME (Size: $SECRET_FILESIZE bytes)"

    # Step 2: Find the next suitable cover file in the list
    COVER_FILE=""
    while [[ -z "$COVER_FILE" ]]; do
        CURRENT_COVER="${COVER_FILES[COVER_INDEX]}"
        COVER_FILENAME=$(basename "$CURRENT_COVER")
        COVER_SIZE=$(stat -c%s "$CURRENT_COVER")

        # Check if the cover file size is large enough
        if (( COVER_SIZE > SECRET_FILESIZE )); then
            COVER_FILE="$CURRENT_COVER"
            echo -e "${GREEN}Selected $COVER_FILENAME as cover file for $SECRET_FILENAME (Size: $COVER_SIZE bytes)${NC}"
        else
            echo -e "${RED}$COVER_FILENAME is too small for $SECRET_FILENAME, trying next file...${NC}"
        fi

        # Increment cover index and wrap around if needed
        COVER_INDEX=$(( (COVER_INDEX + 1) % NUM_COVERS ))
    done

    # Step 3: Embed the secret file into the selected cover file
    if [[ -n "$COVER_FILE" ]]; then
        OUTPUT_FILE="$OUTPUT_DIR/${SECRET_FILENAME%.*}_embedded.${COVER_FILENAME##*.}"
        
        # Embed using steghide
        steghide embed -cf "$COVER_FILE" -ef "$SECRET_FILE" -p "$PASSWORD" -sf "$OUTPUT_FILE"
        echo -e "${GREEN}Embedded $SECRET_FILENAME into $COVER_FILE as $OUTPUT_FILE${NC}"
    else
        echo -e "${RED}No suitable cover file found for $SECRET_FILENAME.${NC}"
    fi
done

echo -e "${GREEN}Process complete.${NC}"
