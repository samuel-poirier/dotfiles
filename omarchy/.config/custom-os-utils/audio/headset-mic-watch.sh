#!/usr/bin/env bash
# Copy the unit service file headset-mic.service from the repo to ~/.config/systemd/user/headset-mic.service
# Then install it and enable it.
# We want to automate running the following when we connect the headset
# pactl set-source-port alsa_input.pci-0000_00_1f.3.analog-stereo analog-input-headset-mic
SRC=alsa_input.pci-0000_00_1f.3.analog-stereo
PREFERRED=analog-input-headset-mic
FALLBACK=analog-input-internal-mic

# With broken jack detection, ports report "availability unknown".
# 1 = assume the headset is plugged in (current behaviour on your machine)
# 0 = assume it isn't, and use the internal mic
UNKNOWN_MEANS_PLUGGED=${UNKNOWN_MEANS_PLUGGED:-1}

src_block() {
  pactl list sources | awk -v RS='' -v s="Name: $SRC" 'index($0, s)'
}

choose_port() {
  local block line
  block=$(src_block)
  [[ -z $block ]] && return 1 # source gone entirely

  line=$(grep -E "^[[:space:]]+$PREFERRED: " <<<"$block")
  case "$line" in
  *"available: yes"*)
    echo "$PREFERRED"
    return 0
    ;;
  *"availability unknown"*)
    ((UNKNOWN_MEANS_PLUGGED)) && {
      echo "$PREFERRED"
      return 0
    }
    ;;
  esac

  grep -qE "^[[:space:]]+$FALLBACK: " <<<"$block" && {
    echo "$FALLBACK"
    return 0
  }
  return 1
}

active_port() {
  src_block | grep -m1 'Active Port:' | awk '{print $3}'
}

apply() {
  local want
  want=$(choose_port) || return
  [[ $want == "$(active_port)" ]] && return # already correct, stay quiet
  pactl set-source-port "$SRC" "$want" || return
  case $want in
  "$PREFERRED") notify-send -a Audio "Microphone" "Headset mic" ;;
  "$FALLBACK") notify-send -a Audio "Microphone" "Internal mic" ;;
  esac
}

apply
pactl subscribe | while read -r line; do
  case "$line" in
  *"on card"* | *"on source"*)
    sleep 0.2
    apply
    ;;
  esac
done
