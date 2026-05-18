#!/bin/sh
# ---------------------------------------------------------------------------
# update.sh  –  install / update the esphomeair Toon app from GitHub Releases
#
# Usage:
#   sh /qmf/qml/apps/esphomeair/update.sh
#
# To run automatically on every boot, add to /etc/rc.local (before exit 0):
#   sh /qmf/qml/apps/esphomeair/update.sh &
# ---------------------------------------------------------------------------

REPO="luukvisser/toon-weer"
INSTALL_DIR="/qmf/qml/apps/esphomeair"
VERSION_FILE="$INSTALL_DIR/version.txt"
TMP_FILE="/tmp/esphomeair-update.tar.gz"
API_URL="https://api.github.com/repos/$REPO/releases"

# ---- read installed version ------------------------------------------------
CURRENT=""
if [ -f "$VERSION_FILE" ]; then
    CURRENT=$(cat "$VERSION_FILE" | tr -d '[:space:]')
fi

# ---- fetch latest release tag from GitHub ----------------------------------
RAW=$(wget -qO- "$API_URL") || { echo "[esphomeair] ERROR: could not reach GitHub API"; exit 1; }

LATEST_TAG=$(echo "$RAW" | grep -o '"tag_name": "esphomeair-v[^"]*"' | head -1 | \
    sed 's/"tag_name": "esphomeair-v//' | sed 's/"//')

if [ -z "$LATEST_TAG" ]; then
    echo "[esphomeair] ERROR: no esphomeair release found in $API_URL"
    exit 1
fi

# ---- compare ---------------------------------------------------------------
if [ "$LATEST_TAG" = "$CURRENT" ]; then
    echo "[esphomeair] already at latest version ($CURRENT) – nothing to do"
    exit 0
fi

echo "[esphomeair] updating from '$CURRENT' → '$LATEST_TAG' ..."

# ---- download --------------------------------------------------------------
TARBALL_URL="https://github.com/$REPO/releases/download/esphomeair-v$LATEST_TAG/esphomeair-v$LATEST_TAG.tar.gz"

wget -O "$TMP_FILE" "$TARBALL_URL" || {
    echo "[esphomeair] ERROR: download failed – $TARBALL_URL"
    rm -f "$TMP_FILE"
    exit 1
}

# ---- install ---------------------------------------------------------------
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_FILE" -C "$INSTALL_DIR" || {
    echo "[esphomeair] ERROR: extraction failed"
    rm -f "$TMP_FILE"
    exit 1
}
rm -f "$TMP_FILE"

echo "[esphomeair] installed version $LATEST_TAG"

# ---- restart Toon QML framework to pick up the new files ------------------
for proc in qb-hmi qb-hmi2; do
    if killall -HUP "$proc" 2>/dev/null; then
        echo "[esphomeair] sent SIGHUP to $proc – app reloading"
        break
    fi
done
