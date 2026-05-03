# ScanDoc — Setup Guide

## Project structure

```
ScanDoc/
├── ScanDocApp.swift          ← @main entry point
├── ContentView.swift         ← UI + save logic
├── DocumentScannerView.swift ← Camera scanner wrapper
└── Info.plist                ← Required permissions
```

## Create the Xcode project

1. **File → New → Project** → *App* (iOS)
2. Name: `ScanDoc`, interface: *SwiftUI*, language: *Swift*
3. Delete the generated `ContentView.swift` and `Assets.xcassets` boilerplate
4. Drag the four files above into the project navigator

## Info.plist

Xcode 14+ uses a Privacy manifest instead of a raw plist by default.
Add the two camera/file keys via **Signing & Capabilities** or paste them
into the generated plist:

| Key | Type | Value |
|-----|------|-------|
| `NSCameraUsageDescription` | String | "Used to scan and digitize documents." |
| `UIFileSharingEnabled` | Boolean | YES |
| `LSSupportsOpeningDocumentsInPlace` | Boolean | YES |

## Where files are saved

PDFs land in **Files app → On My iPhone → ScanDoc**.

Naming convention:
- `S-25 2026-05-03.pdf`
- `S-25 2026-05-03 (2).pdf` ← if you scan twice on the same day

## Requirements

- iOS 16+
- Xcode 15+
- Real device (VNDocumentCameraViewController doesn't run in Simulator)
