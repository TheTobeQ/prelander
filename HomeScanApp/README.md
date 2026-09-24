# HomeScan

HomeScan is an iOS LiDAR room-scanning app built with SwiftUI and Apple RoomPlan.

## What it does

- Scans rooms with RoomPlan and the iPhone LiDAR Scanner.
- Saves multiple rooms in one project.
- Keeps the same AR session between rooms so compatible rooms can be merged.
- Merges rooms into a CapturedStructure.
- Exports the complete structure to USDZ.
- Opens the USDZ in Apple's Quick Look for an interactive 3D view.
- Provides a lightweight 2D wall plan.

## Requirements

- iPhone or iPad with a LiDAR Scanner.
- iOS 17+.
- Mac with Xcode.
- XcodeGen if generating the project from project.yml.

Apple's RoomPlan supports multi-room structures and USDZ export. This app uses the same AR session for successive room scans, then StructureBuilder merges the resulting CapturedRoom values.

## Build

1. Open the HomeScanApp directory on a Mac.
2. Run xcodegen generate.
3. Open HomeScan.xcodeproj in Xcode.
4. Select a physical iPhone with LiDAR.
5. Enable automatic signing and choose your Apple Account team.
6. Build and run.

For personal-device testing, Apple says a free Apple Account can be used as a Personal Team in Xcode, but provisioning must be renewed periodically. App Store distribution requires Apple Developer Program membership.

## Next product layer

The MVP is native and offline-first. Future versions can add project names, saved scan history, PDF floor plans, measurements, furniture editing, cloud backup, and renovation/AI visualization.
