#!/usr/bin/env bash
# set -x

temp="$(mktemp -d)"
curl -o "$temp/hosts" https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

mapfile -t lines < <(grep -v -E '^\s*(#|$)' "$temp/hosts" | awk '{print $2}')

: >/etc/unbound/block.conf

printf '%s\n' "server:" >>/etc/unbound/block.conf

for domain in "${lines[@]:14}"; do
	printf "    local-data: \"%s. A 0.0.0.0\"\n" "$domain" >>/etc/unbound/block.conf
	printf "    local-data: \"%s. AAAA ::1\"\n" "$domain" >>/etc/unbound/block.conf
done
