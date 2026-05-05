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
    @State private var showSavedText = false
    @State private var showBranding = true

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

                // Saved confirmation overlay
                if showSavedText {
                    Text("Saved.")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
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

            Text("Simply Scan")
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
                showSavedText = true

                // Hold, then disappear
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showSavedText = false
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
