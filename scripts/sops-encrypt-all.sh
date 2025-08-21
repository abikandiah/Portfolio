#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

secret_file=../secrets.yaml
encrypted_file=../secrets.sops.yaml


if [ -f "$encrypted_file" ]; then
    # Decrypt encrypted version
    decrypted_temp=$(mktemp)
    sops --decrypt "$encrypted_file" > "$decrypted_temp"

    # Compare decrypted version with file on disk
    if cmp -s "$secret_file" "$decrypted_temp"; then
        echo -e "${GREEN}No changes detected. Skipping encryption for file: $secret_file${NC}"
    else
        echo -e "${RED}Changes detected. Re-encrypting file: $secret_file${NC}"
        sops --encrypt "$secret_file" > "$encrypted_file"
    fi

    rm "$decrypted_temp"
else
    # Encrypted version does not exist, encrypt file
    echo -e "${RED}Encrypting file: $secret_file${NC}"
    sops --encrypt "$secret_file" > "$encrypted_file"
fi



