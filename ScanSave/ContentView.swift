import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("filePrefix") private var filePrefix = "S-24"
    @AppStorage("dateFormat") private var dateFormatRaw = "yyyy-MM-dd"

    @State private var showingScanner = false
    @State private var showingSettings = false
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)

                Text("ScanSave")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Scan a document and it's\nautomatically saved as a PDF.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                if isProcessing {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    Button(action: { showingScanner = true }) {
                        Label("Scan Document", systemImage: "camera.viewfinder")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal, 40)
                }

                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
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
        }
    }

    private func handleScanResult(_ images: [UIImage]) {
        guard !images.isEmpty else { return }

        isProcessing = true

        let dateFormat = DateFormat(rawValue: dateFormatRaw) ?? .dateOnly
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.rawValue
        let dateString = formatter.string(from: Date())
        let prefix = filePrefix.trimmingCharacters(in: .whitespaces)
        let fileName = "\(prefix)_\(dateString).pdf"

        DispatchQueue.global(qos: .userInitiated).async {
            PDFGenerator.generatePDF(from: images, fileName: fileName)

            DispatchQueue.main.async {
                isProcessing = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}

#Preview {
    ContentView()
}
