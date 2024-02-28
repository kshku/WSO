#!/bin/sh

script_url="https://raw.githubusercontent.com/kshku/WSO/main/wso.sh"
install_dir="/usr/local/bin"

if command -v curl > /dev/null; then
    curl -sSLo "$install_dir/wso" "$script_url"
elif command -v wget > /dev/null; then
    wget -qO "$install_dir/wso" "$script_url"
else
    echo "Error: Neither curl nor wget found. Please install one of them to proceed"
    exit 1
fi

chmod +x "$install_dir/wso"

echo "wso has been installed to $install_dir"
