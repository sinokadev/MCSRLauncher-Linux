#!/usr/bin/env bash
set -euo pipefail

JAR_URL="https://github.com/MCSRLauncher/Launcher/releases/latest/download/MCSRLauncher.jar"
ICON_URL="https://avatars.githubusercontent.com/u/181990097?s=256"
BUILD_SH_URL="https://raw.githubusercontent.com/sinokadev/MCSRLauncher-Linux/refs/heads/main/build.sh"

DIST_DIR="./dist"
ASSETS_DIR="./assets"

mkdir -p "$DIST_DIR" "$ASSETS_DIR"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing command: $1"
    exit 1
  }
}

need_cmd curl

echo "[*] downloading latest MCSRLauncher.jar ..."

if ! curl -fL -o "$DIST_DIR/MCSRLauncher.jar" "$JAR_URL"; then
  echo "MCSRLauncher.jar not found in latest release"
  exit 1
fi

echo "[+] MCSRLauncher.jar downloaded"

echo "[*] downloading icon ..."
curl -fL -o "$ASSETS_DIR/icon.png" "$ICON_URL"

echo "[*] downloading build.sh ..."
curl -fL -o "./build.sh" "$BUILD_SH_URL"
chmod +x ./build.sh

echo "[*] running build.sh ..."
./build.sh

echo
echo "[+] Build finished successfully!"
echo
echo "You can now run MCSRLauncher with:"
echo
echo "  chmod +x MCSRLauncher-x86_64.AppImage"
echo "  ./MCSRLauncher-x86_64.AppImage"
echo
echo "If the file name is different, list available AppImages with:"
echo
echo "  ls *.AppImage"
echo
echo "[+] done"
