# AGENTS.md

## Verifying the Example with Xcode

`Example.swiftpm` is a SwiftPM iOS application. `swift build` and `swift test` resolve for macOS and cannot build UIKit-based targets. Verify Example changes with `xcodebuild` using Xcode's iOS SDK.

Run the following from the repository root:

```sh
cd Example.swiftpm
xcodebuild \
  -scheme Example \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/header-example-derived \
  build
```

For dependency updates, run the same command and inspect `Package.resolved` as well.

On success, the output ends with `** BUILD SUCCEEDED **`. For simulator verification, replace `generic/platform=iOS` with an installed iOS Simulator destination.
