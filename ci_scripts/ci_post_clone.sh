#
//  ci_post_clone.sh
//  SplitIn
//
//  Created by Miranda Utami on 21/07/26.
//

#!/bin/sh

# Pindah ke root folder project
cd "$(dirname "$0")/.."

echo "=== Pre-building Test Bundle for Xcode Cloud ==="

# Build test bundle dan letakkan langsung di TestProducts
xcodebuild build-for-testing \
  -scheme SplitIn \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -testPlan SplitIn \
  -derivedDataPath /Volumes/workspace/DerivedData

# Copy hasil build tes ke folder yang dicari Runner Action Test
mkdir -p /Volumes/workspace/TestProducts.xctestproducts
cp -R /Volumes/workspace/DerivedData/Build/Products/* /Volumes/workspace/TestProducts.xctestproducts/ 2>/dev/null || true
