#!/usr/bin/env sh
# Original Author: Gerharddc/Litterbox
# Modified by Voidus_X for Sparrow.

set -e

REPO="Gerharddc/litterbox"
INSTALL_DIR="/usr/bin"
BINARIES="litterbox lbx-init"

ARCH="$(uname -m)"

# --- ARCH CHECK (only x86-64 supported) ---
case "$ARCH" in
  x86_64|amd64)
    # OK
    ;;
  *)
    echo "Litterbox: Unsupported architecture detected: $ARCH"
    echo "condition skipped"
    exit 0
    ;;
esac
# ------------------------------------------

echo "Installing Litterbox"
echo ""

# Ensure install dir exists
if [ ! -d "$INSTALL_DIR" ]; then
  mkdir -p "$INSTALL_DIR"
fi

for BIN in $BINARIES; do
  DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/$BIN"
  curl -fL "$DOWNLOAD_URL" -o "$INSTALL_DIR/$BIN"
  chmod +x "$INSTALL_DIR/$BIN"
done

echo ""

# PATH check
case ":$PATH:" in
  *:"$INSTALL_DIR":*)
    # OK
    ;;
  *)
    echo "Litterbox is not in PATH."
    echo "A patch is required to fix this issue, this is a bug."
    ;;
esac

echo "Litterbox installed."
