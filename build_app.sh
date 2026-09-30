#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "🔨 Mengompilasi Mactive (Release)..."
swift build -c release

APP_NAME="Mactive.app"
BUILD_DIR="$DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "📦 Menyiapkan App Bundle ($APP_NAME)..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp "$DIR/.build/release/mactive" "$MACOS_DIR/mactive"
chmod +x "$MACOS_DIR/mactive"

# Copy Icon
if [ -f "$DIR/AppIcon.icns" ]; then
    cp "$DIR/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

# Create Info.plist
cat << 'EOF' > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>mactive</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.ree.mactive</string>
    <key>CFBundleName</key>
    <string>Mactive</string>
    <key>CFBundleDisplayName</key>
    <string>Mactive</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "🔏 Menandatangani aplikasi (ad-hoc codesign)..."
codesign --force --deep --sign - "$APP_DIR"

echo "✅ Berhasil dibuat: $APP_DIR"
echo "Untuk menjalankan, ketik: open \"$APP_DIR\""
