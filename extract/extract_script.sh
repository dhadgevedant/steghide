#!/bin/bash

# Directories
EMBEDDED_DIR="embedded_files"   # Directory with embedded files
OUTPUT_SECRET_DIR="extracted_files" # Directory to store extracted secret files
PASSWORD="pass"                  # Password for extraction

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No color

# Enable nullglob to handle cases with no matching files
shopt -s nullglob

# Ensure the output directory exists
mkdir -p "$OUTPUT_SECRET_DIR"

# Step 1: Iterate over each embedded file in EMBEDDED_DIR
for EMBEDDED_FILE in "$EMBEDDED_DIR"/*; do
    # Get the file name
    EMBEDDED_FILENAME=$(basename "$EMBEDDED_FILE")

    # Skip the IDENTIFIER file or any file containing 'Zone.Identifier'
    if [[ "$EMBEDDED_FILENAME" == "IDENTIFIER" || "$EMBEDDED_FILENAME" == *Zone.Identifier* ]]; then
        echo -e "${RED}Skipping $EMBEDDED_FILENAME...${NC}"
        continue  # Skip this iteration and move to the next file
    fi

    # Get the original file extension
    EMBEDDED_EXTENSION="${EMBEDDED_FILENAME##*.}"  # Get the file extension

    echo "Processing $EMBEDDED_FILENAME for extraction..."

    # Step 2: Extract the secret file using steghide
    # Use a temporary location to store the extracted file
    TEMP_FILE=$(mktemp)

    # Run the extraction
    steghide extract -sf "$EMBEDDED_FILE" -p "$PASSWORD" -q -xf "$TEMP_FILE" -f

    if [[ $? -eq 0 ]]; then
        # Move the extracted file to the OUTPUT_SECRET_DIR with its original name and extension
        mv "$TEMP_FILE" "$OUTPUT_SECRET_DIR/${EMBEDDED_FILENAME%.*}.$EMBEDDED_EXTENSION"  # Retaining the original extension
        echo -e "${GREEN}Successfully extracted secret file from $EMBEDDED_FILENAME.${NC}"
    else
        echo -e "${RED}Failed to extract secret file from $EMBEDDED_FILENAME. It might not contain a hidden file or the password is incorrect.${NC}"
        rm "$TEMP_FILE"  # Clean up temporary file in case of failure
    fi
done

echo -e "${GREEN}Extraction process complete.${NC}"
