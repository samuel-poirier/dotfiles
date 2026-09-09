hyprctl clients -j | jq -r '.[].address' | while read -r a; do
  hyprctl dispatch movetoworkspacesilent "1,address:$a"
done
