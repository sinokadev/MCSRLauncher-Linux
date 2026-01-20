#!/usr/bin/env bash
set -euo pipefail

# =========================
# MCSRLauncher AppImage build script
# - Inputs: dist/MCSRLauncher.jar, optional icon at assets/myapp.png
# - Output: MCSRLauncher-x86_64.AppImage
# =========================

APP_NAME="MCSRLauncher"
MAIN_JAR="MCSRLauncher.jar"
MAIN_CLASS="com.redlimerl.mcsrlauncher.MCSRLauncher"

# Paths (relative to this script)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
ASSETS_DIR="$ROOT_DIR/assets"
BUILD_DIR="$ROOT_DIR/build"
TOOLS_DIR="$ROOT_DIR/tools"
APPDIR="$ROOT_DIR/${APP_NAME}.AppDir"

# Icon (optional, but appimagetool usually expects it if Icon= is in .desktop)
ICON_SRC_PNG="$ASSETS_DIR/icon.png"
ICON_DST_PNG="$APPDIR/${APP_NAME}.png"

# appimagetool
APPIMAGETOOL="$TOOLS_DIR/appimagetool-x86_64.AppImage"
APPIMAGETOOL_URL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"

# Detect arch (basic)
ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" && "$ARCH" != "amd64" ]]; then
  echo "[-] This script is configured for x86_64. Detected: $ARCH"
  echo "    If you are on aarch64/armhf, download the matching appimagetool and adjust ARCH var."
  exit 1
fi

echo "[*] Root: $ROOT_DIR"

# ---- sanity checks
if ! command -v jpackage >/dev/null 2>&1; then
  echo "[-] jpackage not found. Install a JDK that includes jpackage (e.g., JDK 17+)."
  exit 1
fi

if [[ ! -f "$DIST_DIR/$MAIN_JAR" ]]; then
  echo "[-] Missing: $DIST_DIR/$MAIN_JAR"
  echo "    Put your jar at: dist/$MAIN_JAR"
  exit 1
fi

# ---- optional: show manifest Main-Class (informational)
echo "[*] Checking JAR manifest (optional)..."
if command -v unzip >/dev/null 2>&1; then
  unzip -p "$DIST_DIR/$MAIN_JAR" META-INF/MANIFEST.MF 2>/dev/null | sed -n '1,80p' || true
fi

# ---- fetch appimagetool if missing
mkdir -p "$TOOLS_DIR"
if [[ ! -f "$APPIMAGETOOL" ]]; then
  echo "[*] Downloading appimagetool..."
  if command -v curl >/dev/null 2>&1; then
    curl -L -o "$APPIMAGETOOL" "$APPIMAGETOOL_URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$APPIMAGETOOL" "$APPIMAGETOOL_URL"
  else
    echo "[-] Need curl or wget to download appimagetool."
    exit 1
  fi
  chmod +x "$APPIMAGETOOL"
fi

# ---- clean previous outputs
echo "[*] Cleaning old outputs..."
rm -rf "$BUILD_DIR" "$APPDIR" "$ROOT_DIR"/*.AppImage
mkdir -p "$BUILD_DIR"

# ---- jpackage: create app-image
echo "[*] Running jpackage (app-image)..."
jpackage \
  --type app-image \
  --name "$APP_NAME" \
  --input "$DIST_DIR" \
  --main-jar "$MAIN_JAR" \
  --main-class "$MAIN_CLASS" \
  --dest "$BUILD_DIR"

# ---- quick run check (optional; comment out if you don't want)
echo "[*] Built app-image. Executable should be at: $BUILD_DIR/$APP_NAME/bin/$APP_NAME"
if [[ ! -x "$BUILD_DIR/$APP_NAME/bin/$APP_NAME" ]]; then
  echo "[-] Expected executable not found/executable: $BUILD_DIR/$APP_NAME/bin/$APP_NAME"
  echo "    Listing build dir:"
  find "$BUILD_DIR/$APP_NAME" -maxdepth 3 -type f -print || true
  exit 1
fi

# ---- build AppDir structure for appimagetool
echo "[*] Creating AppDir..."
mkdir -p "$APPDIR/usr"
cp -a "$BUILD_DIR/$APP_NAME/"* "$APPDIR/usr/"

# AppRun
cat > "$APPDIR/AppRun" <<EOF
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\$0")")"
exec "\$HERE/usr/bin/$APP_NAME" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

# Desktop entry
cat > "$APPDIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$APP_NAME
Exec=$APP_NAME
Icon=$APP_NAME
Categories=Game;
Terminal=false
EOF

# Icon (recommended). If missing, we will drop Icon line to avoid hard failure.
if [[ -f "$ICON_SRC_PNG" ]]; then
  echo "[*] Copying icon: $ICON_SRC_PNG -> $ICON_DST_PNG"
  cp "$ICON_SRC_PNG" "$ICON_DST_PNG"

  # Optional: strip ICC profile warnings if ImageMagick exists (non-fatal if not)
  if command -v magick >/dev/null 2>&1; then
    magick "$ICON_DST_PNG" -strip "$ICON_DST_PNG" || true
  elif command -v convert >/dev/null 2>&1; then
    convert "$ICON_DST_PNG" -strip "$ICON_DST_PNG" || true
  fi
else
  echo "[!] Icon not found at $ICON_SRC_PNG"
  echo "    appimagetool may fail if Icon is referenced. Removing Icon= line from .desktop..."
  # remove Icon line
  sed -i '/^Icon=/d' "$APPDIR/$APP_NAME.desktop"
fi

# ---- create AppImage
echo "[*] Packaging AppImage..."
ARCH=x86_64 "$APPIMAGETOOL" "$APPDIR"

echo "[+] Done."
echo "[+] Output:"
ls -la "$ROOT_DIR"/*.AppImage
echo
echo "Run it with:"
echo "  chmod +x ./${APP_NAME}-x86_64.AppImage"
echo "  ./${APP_NAME}-x86_64.AppImage"
