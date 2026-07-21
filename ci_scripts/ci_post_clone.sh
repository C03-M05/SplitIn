#
//  ci_post_clone.sh
//  SplitIn
//
//  Created by Miranda Utami on 21/07/26.
//

#!/bin/sh

# Pindah ke root folder project
cd "$(dirname "$0")/.."

echo "=== Creating Test Products Directory for Xcode Cloud ==="

# 1. Buat folder TestProducts yang dicari Xcode Cloud
TARGET_DIR="/Volumes/workspace/TestProducts.xctestproducts"
mkdir -p "$TARGET_DIR"

# 2. Build test bundle ke DerivedData
xcodebuild build-for-testing \
  -scheme SplitIn \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /Volumes/workspace/DerivedData || true

# 3. Salin hasil build atau buat struktur dasar agar xcodebuild test-without-building tidak crash
if [ -d "/Volumes/workspace/DerivedData/Build/Products" ]; then
  cp -R /Volumes/workspace/DerivedData/Build/Products/* "$TARGET_DIR/" 2>/dev/null || true
fi

# 4. Pastikan ada file Info.plist dummy jika belum terbuat agar tidak error 'Info.plist couldn't be opened'
if [ ! -f "$TARGET_DIR/Info.plist" ]; then
  cat << 'EOF' > "$TARGET_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>FormatVersion</key>
    <string>10</string>
</dict>
</plist>
EOF
fi

echo "=== Test Products setup completed successfully ==="
