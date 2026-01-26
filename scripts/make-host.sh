#!/usr/bin/env bash

temp=$(mktemp -d)
cleanup() {
	rm -rf "$temp"
}
trap cleanup EXIT

host=$1
target=$2

install -d -m755 "$temp/etc/sops"
age-keygen -o "$temp/etc/sops/keys.txt"

pubkey="$(age-keygen -y "$temp/etc/sops/keys.txt")"

echo "Add this to .sops.yaml under $host: $pubkey"
read -p -r "Press Enter to continue" </dev/tty

nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake ".#$host" --target-host "$target" --generate-hardware-config nixos-generate-config "/home/gleask/nixos/hosts/$host/hardware-configuration.nix" --vm-test
