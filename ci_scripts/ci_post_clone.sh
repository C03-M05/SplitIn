#
//  ci_post_clone.sh
//  SplitIn
//
//  Created by Miranda Utami on 21/07/26.
//

#!/bin/sh

# Pindah ke root directory repository
cd "$(dirname "$0")/.."

echo "=== Building test products for Xcode Cloud ==="

# Menjalankan build-for-testing dan mengekspor hasilnya ke lokasi TestProducts
xcodebuild build-for-testing \
  -scheme SplitIn \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -testPlan SplitIn \
  -derivedDataPath /Volumes/workspace/DerivedData
