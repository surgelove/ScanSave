import SwiftUI
import UIKit
import os

/// The main screen of ScanSave.
///
/// Shows a "Scan Document" button that opens the document camera.
/// After scanning, the PDF is generated and saved automatically without further interaction.
struct ContentView: View {

    // MARK: - Persisted Settings

    @AppStorage("filePrefix") private var filePrefix = "prefix"
    @AppStorage("dateFormat") private var dateFormatRaw = "yyyy-MM-dd HH'h'mm'm'ss's'"
    @AppStorage("autoScanOnLaunch") private var autoScanOnLaunch = false
    @AppStorage("saveFormat") private var saveFormat = "pdf"

    // MARK: - State

    @State private var showingScanner = false
    @State private var showingSettings = false
    @State private var isProcessing = false
    @State private var showSavedImage = false
    @State private var showBranding = true
    @State private var imageScale: CGFloat = 0.3

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.scansave", category: "ContentView")

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 30) {
                    Spacer()

                    if showBranding {
                        brandingContent
                    }

                    Spacer()

                    if isProcessing {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else if showBranding {
                        scanButton
                    }

                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        settingsButton
                    }
                }

                // Robot overlay centered in the screen
                if showSavedImage {
                    Image("scanrobotsaved")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageScale * 300, height: imageScale * 300)
                        .shadow(color: .black.opacity(0.3), radius: 20)
                        .animation(.easeOut(duration: 0.5), value: imageScale)
                }
            }
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView { images in
                    handleScanResult(images)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                if autoScanOnLaunch {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showingScanner = true
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var brandingContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.viewfinder")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            Text("ScanSave")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Scan. Saved. Done.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var scanButton: some View {
        Button(action: { showingScanner = true }) {
            Label("Scan Document", systemImage: "camera.viewfinder")
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.horizontal, 40)
    }

    private var settingsButton: some View {
        Button(action: { showingSettings = true }) {
            Image(systemName: "gearshape")
                .accessibilityLabel("Settings")
        }
    }

    // MARK: - Scan Handling

    private func handleScanResult(_ images: [UIImage]) {
        guard !images.isEmpty else {
            logger.info("Scan returned no images.")
            return
        }

        isProcessing = true

        let dateFormat = DateFormat(rawValue: dateFormatRaw) ?? .dateOnly
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.rawValue
        let dateString = formatter.string(from: Date())
        let prefix = filePrefix.trimmingCharacters(in: .whitespaces)
        let ext = saveFormat == "png" ? "png" : "pdf"
        let fileName = "\(prefix) \(dateString).\(ext)"

        logger.info("Saving \(ext.uppercased()): \(fileName)")

        DispatchQueue.global(qos: .userInitiated).async {
            if saveFormat == "png" {
                PNGGenerator.saveAsPNG(from: images, fileName: fileName)
            } else {
                PDFGenerator.generatePDF(from: images, fileName: fileName)
            }

            DispatchQueue.main.async {
                isProcessing = false
                imageScale = 0.2
                showBranding = false
                showSavedImage = true

                // Grow to full size over 0.5s
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    imageScale = 1.0
                }

                // Hold, then disappear
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showSavedImage = false
                        showBranding = true
                    }
                }

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}

#Preview {
    ContentView()
}
