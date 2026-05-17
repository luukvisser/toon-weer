#!/bin/sh
# ---------------------------------------------------------------------------
# update.sh  –  install / update the Co2 Toon app from GitHub Releases
#
# Usage:
#   sh /qmf/qml/apps/co2/update.sh
#
# To run automatically on every boot, add to /etc/rc.local (before exit 0):
#   sh /qmf/qml/apps/co2/update.sh &
# ---------------------------------------------------------------------------

REPO="luukvisser/toon-weer"
INSTALL_DIR="/qmf/qml/apps/co2"
VERSION_FILE="$INSTALL_DIR/version.txt"
TMP_FILE="/tmp/co2-update.tar.gz"
API_URL="https://api.github.com/repos/$REPO/releases"

# ---- read installed version ------------------------------------------------
CURRENT=""
if [ -f "$VERSION_FILE" ]; then
    CURRENT=$(cat "$VERSION_FILE" | tr -d '[:space:]')
fi

# ---- fetch latest release tag from GitHub ----------------------------------
RAW=$(wget -qO- "$API_URL") || { echo "[co2-update] ERROR: could not reach GitHub API"; exit 1; }

LATEST_TAG=$(echo "$RAW" | grep -o '"tag_name": "co2-v[^"]*"' | head -1 | \
    sed 's/"tag_name": "co2-v//' | sed 's/"//')

if [ -z "$LATEST_TAG" ]; then
    echo "[co2-update] ERROR: no co2 release found in $API_URL"
    exit 1
fi

# ---- compare ---------------------------------------------------------------
if [ "$LATEST_TAG" = "$CURRENT" ]; then
    echo "[co2-update] already at latest version ($CURRENT) – nothing to do"
    exit 0
fi

echo "[co2-update] updating from '$CURRENT' → '$LATEST_TAG' ..."

# ---- download --------------------------------------------------------------
TARBALL_URL="https://github.com/$REPO/releases/download/co2-v$LATEST_TAG/co2-v$LATEST_TAG.tar.gz"

wget -O "$TMP_FILE" "$TARBALL_URL" || {
    echo "[co2-update] ERROR: download failed – $TARBALL_URL"
    rm -f "$TMP_FILE"
    exit 1
}

# ---- install ---------------------------------------------------------------
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_FILE" -C "$INSTALL_DIR" || {
    echo "[co2-update] ERROR: extraction failed"
    rm -f "$TMP_FILE"
    exit 1
}
rm -f "$TMP_FILE"

echo "[co2-update] installed version $LATEST_TAG"

# ---- restart Toon QML framework to pick up the new files ------------------
# The HMI process name differs between Toon 1 (qb-hmi) and Toon 2/Nxt (qb-hmi2).
# Sending SIGHUP asks the process to reload without a full reboot.
for proc in qb-hmi qb-hmi2; do
    if killall -HUP "$proc" 2>/dev/null; then
        echo "[co2-update] sent SIGHUP to $proc – app reloading"
        break
    fi
done
