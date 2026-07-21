#
//  ci_post_clone.sh
//  SplitIn
//
//  Created by Miranda Utami on 21/07/26.
//

#!/bin/sh

# Memaksa Xcode Cloud me-build file tes sebelum pengujian berjalan
echo "=== Building test products for Xcode Cloud ==="
xcodebuild build-for-testing \
  -scheme SplitIn \
  -destination 'platform=iOS Simulator,name=iPhone 17'
