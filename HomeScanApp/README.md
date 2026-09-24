# HomeScan — iPhone LiDAR Home Scanner

Native iOS MVP using SwiftUI + Apple RoomPlan.

## What it does
- Scans rooms using LiDAR on supported iPhones (including iPhone 14 Pro)
- Detects walls, doors, windows and openings
- Shows scan progress
- Presents captured room dimensions
- Exports the captured room as USDZ for viewing in AR/3D apps
- Includes a simple 2D floor-plan view

## Requirements
- Xcode 15+
- iOS 16+
- Physical iPhone/iPad with LiDAR
- Camera permission

## Run
Create/open an iOS App project in Xcode named HomeScan, then add the Swift files from this folder to the target. Set the bundle identifier as desired and run on a physical LiDAR device.

RoomPlan does not work in the iOS Simulator.
