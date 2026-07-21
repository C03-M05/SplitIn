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

# Minta xcodebuild me-build DAN mengekspor langsung ke folder TestProducts
xcodebuild build-for-testing \
  -scheme SplitIn \
  -destination 'generic/platform=iOS Simulator' \
  -testPlan SplitIn \
  -testProductsPath /Volumes/workspace/TestProducts.xctestproducts
