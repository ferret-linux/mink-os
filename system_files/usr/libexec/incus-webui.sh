#!/bin/bash

FAKEBIN=$(mktemp -d)
cat > "$FAKEBIN/xdg-open" << 'INNER'
#!/bin/bash
echo "$1" > /tmp/incus-webui-url.txt
INNER
chmod +x "$FAKEBIN/xdg-open"

rm -f /tmp/incus-webui-url.txt /tmp/incus-webui.log

PATH="$FAKEBIN:$PATH" incus webui > /tmp/incus-webui.log 2>&1 &
INCUS_PID=$!

URL=""
for _ in $(seq 1 50); do
    [ -s /tmp/incus-webui-url.txt ] && URL=$(cat /tmp/incus-webui-url.txt) && break
    sleep 0.2
done

if [ -z "$URL" ]; then
    notify-send "Incus" "Failed to get web UI URL" 2>/dev/null
    rm -rf "$FAKEBIN"
    exit 1
fi

PROFILE_DIR="$HOME/.local/share/incus-webui-profile"

EXTRA_FLAGS=()
if command -v xrandr &>/dev/null; then
    RES=$(xrandr --current | grep '\*' | head -n1 | awk '{print $1}')
    SCREEN_W=$(echo "$RES" | cut -dx -f1)
    SCREEN_H=$(echo "$RES" | cut -dx -f2)
fi

if [ -n "$SCREEN_W" ] && [ -n "$SCREEN_H" ]; then
    WIN_W=$(( SCREEN_W * 45 / 100 ))
    WIN_H=$(( SCREEN_H * 45 / 100 ))
    EXTRA_FLAGS=(--window-size="${WIN_W},${WIN_H}")
fi

helium --app="$URL" --name=Incus --class=Incus --user-data-dir="$PROFILE_DIR" "${EXTRA_FLAGS[@]}"

kill "$INCUS_PID" 2>/dev/null
rm -rf "$FAKEBIN"
rm -f /tmp/incus-webui-url.txt