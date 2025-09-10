#!/usr/bin/env bash

declare -A URLS
URLS=(
  ["Drive"]="https://drive.google.com/drive/"
  # This is silly and hardcoded. Only works if you signed in to work drive second
  ["Work drive"]="https://drive.google.com/drive/u/1/"
  ["Mail"]="https://mail.google.com/mail/"
  # Same as above comment
  ["Work mail"]="https://mail.google.com/mail/u/1/"
  ["Calendar"]="https://calendar.google.com/calendar/"
)
list() {
    for i in "${!URLS[@]}"
    do
      echo "$i"
    done
}
main() {
  platform=$( (list) | rofi -dmenu -matching fuzzy -no-custom -i -p "Open google... " )

  if [[ -n "$platform" ]]; then
    url=${URLS[$platform]}
    xdg-open "$url"
  else
    exit
  fi
}
main
exit 0
