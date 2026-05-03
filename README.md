# ScanSave 📄

**ScanSave** is a minimal iOS document scanner that automatically saves each scan as a PDF — no extra taps, no confirmation dialogs.

<p align="center">
  <img src="ScanSave/Assets.xcassets/AppIcon.appiconset/icon-ios-marketing-1024x1024-1x.png" width="128" alt="ScanSave Icon">
</p>

## Features

- 📷 **One-tap scanning** — Open the document camera, scan, and the PDF is saved instantly.
- ⚙️ **Configurable file names** — Choose a custom prefix and date format in Settings.
- 📂 **Files app integration** — All PDFs are visible in the Files app under *On My iPhone → ScanSave*.
- 🤖 **Zero intervention** — No share sheets, no previews, no confirmation alerts.

## File Naming

The naming pattern is `{prefix} {date}.pdf`. You can configure both the prefix and the date format:

| Date Format           | Example Output                        |
|-----------------------|---------------------------------------|
| `YYYY-MM-DD`          | `S-24 2026-05-03.pdf`                 |
| `YYYY-MM-DD HHhMM`    | `S-24 2026-05-03 16h53.pdf`           |
| `YYYY-MM-DD HHhMMmSSs`| `S-24 2026-05-03 16h53m47s.pdf`       |

## Requirements

- iOS 17.0+
- Xcode 15+
- A physical iPhone with a camera (the document scanner is not available on simulators)

## Getting Started

1. Open `ScanSave.xcodeproj` in Xcode.
2. Select your development team under **Signing & Capabilities**.
3. Connect your iPhone and press **Cmd+R**.
4. On the first run, trust the developer certificate on your device (*Settings → General → VPN & Device Management*).

## Project Structure

```
ScanSave/
├── ScanSave.xcodeproj/         # Xcode project file
├── ScanSave/
│   ├── ScanSaveApp.swift       # App entry point
│   ├── ContentView.swift       # Main screen & scan flow
│   ├── SettingsView.swift      # File name configuration
│   ├── DateFormat.swift        # Date format options
│   ├── DocumentScannerView.swift # VisionKit wrapper
│   ├── PDFGenerator.swift      # PDF generation logic
│   ├── Assets.xcassets/        # App icon assets
│   └── Info.plist              # App configuration
├── scansavecylon.png           # Custom app icon source
└── README.md
```

## Tech Stack

- **SwiftUI** — Modern declarative UI
- **VisionKit** — Document scanning via `VNDocumentCameraViewController`
- **PDFKit** — PDF generation from scanned images
- **`os` Logger** — Structured logging instead of `print()`

## License

This project is provided for personal and educational use.
