import SwiftUI
import UIKit
import os

/// The main screen of ScanSave.
///
/// Shows a "Scan Document" button that opens the document camera.
/// After scanning, the PDF is generated and saved automatically without further interaction.
struct ContentView: View {

    // MARK: - Persisted Settings

    @AppStorage("filePrefix") private var filePrefix = "S-24"
    @AppStorage("dateFormat") private var dateFormatRaw = "yyyy-MM-dd"
    @AppStorage("autoScanOnLaunch") private var autoScanOnLaunch = false

    // MARK: - State

    @State private var showingScanner = false
    @State private var showingSettings = false
    @State private var isProcessing = false
    @State private var showSavedToast = false
    @State private var savedFileName = ""

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.scansave", category: "ContentView")

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                brandingContent

                Spacer()

                if isProcessing {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    scanButton
                }

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
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
            .toast(
                isPresented: $showSavedToast,
                message: savedFileName,
                systemImage: "checkmark.circle.fill"
            )
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

            Text("Scan a document and it's automatically saved as a PDF.")
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
        let fileName = "\(prefix) \(dateString).pdf"

        logger.info("Saving PDF: \(fileName)")

        DispatchQueue.global(qos: .userInitiated).async {
            PDFGenerator.generatePDF(from: images, fileName: fileName)

            DispatchQueue.main.async {
                isProcessing = false
                savedFileName = fileName
                showSavedToast = true
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
