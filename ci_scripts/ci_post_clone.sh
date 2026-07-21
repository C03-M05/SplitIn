#
//  ci_post_clone.sh
//  SplitIn
//
//  Created by Miranda Utami on 21/07/26.
//

#!/bin/sh

# Move up to repository root folder where .xcodeproj / .xcworkspace lives
cd "$(dirname "$0")/.."

echo "=== Building test products for Xcode Cloud ==="

xcodebuild build-for-testing \
  -scheme SplitIn \
  -destination 'platform=iOS Simulator,name=iPhone 17'
