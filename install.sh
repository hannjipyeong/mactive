#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "🚀 Memulai proses instalasi Mactive..."
./build_app.sh

echo "🛑 Menghentikan proses Mactive yang sedang berjalan jika ada..."
pkill -f "Mactive.app/Contents/MacOS/mactive" || true
sleep 1

DEST="/Applications/Mactive.app"
echo "📂 Memindahkan ke $DEST..."
rm -rf "$DEST"
cp -R "$DIR/build/Mactive.app" /Applications/

echo "✨ Membuka Mactive dari folder Applications..."
open "$DEST"

echo ""
echo "🎉 Berhasil! Aplikasi Mactive sekarang aktif di menu bar atas MacBook kamu (sejajar baterai dan Wi-Fi)."
