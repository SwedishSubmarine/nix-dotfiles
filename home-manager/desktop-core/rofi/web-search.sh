#!/usr/bin/env bash

declare -A URLS
URLS=(
  ["duckduckgo"]="https://www.duckduckgo.com/?q="
  ["nixpkgs"]="https://search.nixos.org/packages?query="
  ["nixopts"]="https://search.nixos.org/options?query="
  ["home-manager"]="https://home-manager-options.extranix.com/?query="
)
list() {
    for i in "${!URLS[@]}"
    do
      echo "$i"
    done
}
main() {
  platform=$( (list) | rofi -dmenu -matching fuzzy -no-custom -i -p "Platform > " )

  if [[ -n "$platform" ]]; then
    query=$( (echo ) | rofi  -dmenu -matching fuzzy -i -p "$platform > " )

    if [[ -n "$query" ]]; then
      url=${URLS[$platform]}$query
      xdg-open "$url"
    else
      exit
    fi

  else
    exit
  fi
}
main
exit 0
