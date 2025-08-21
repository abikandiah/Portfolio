#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

secret_file=../secrets.yaml
encrypted_file=../secrets.sops.yaml


force=false

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -f | --force)
        force=true
        shift
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

if [ -f "$secret_file" ]; then
    # Decrypt encrypted version
    decrypted_temp=$(mktemp)
    sops --decrypt "$encrypted_file" >"$decrypted_temp"

    # Compare decrypted version with the existing decrypted file
    if cmp -s "$secret_file" "$decrypted_temp"; then
        echo -e "${GREEN}No changes detected. Skipping decryption for file: $encrypted_file${NC}"
    else
        if [ "$force" = true ]; then
            mv "$decrypted_temp" "$secret_file"
            echo -e "${RED}File replaced with the decrypted content: $secret_file${NC}"
        else
            echo -e "${RED}Changes detected. Use -f or --force flag to overwrite $encrypted_file${NC}"
        fi
    fi

    if [ -f "$decrypted_temp" ]; then
        rm "$decrypted_temp"
    fi
else
    # No decrypted file exists, decrypt and create it
    echo -e "${RED}Decrypting file: $encrypted_file${NC}"
    sops --decrypt "$encrypted_file" >"$secret_file"
fi
