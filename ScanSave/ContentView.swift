import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showingScanner = false
    @State private var isProcessing = false
    @State private var savedFileName: String?
    @State private var showConfirmation = false

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
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Saving PDF…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button(action: { showingScanner = true }) {
                        Label("Scan Document", systemImage: "camera.viewfinder")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal, 40)
                }

                if let name = savedFileName {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Saved: \(name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 10)
                }

                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView { images in
                    handleScanResult(images)
                }
            }
            .alert("PDF Saved", isPresented: $showConfirmation) {
                Button("Scan Another", role: .cancel) {
                    savedFileName = nil
                }
            } message: {
                if let name = savedFileName {
                    Text("\(name) was saved to the ScanSave folder.\nYou can find it in the Files app.")
                }
            }
        }
    }

    private func handleScanResult(_ images: [UIImage]) {
        guard !images.isEmpty else { return }

        isProcessing = true

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        let fileName = "S-24_\(dateString).pdf"

        DispatchQueue.global(qos: .userInitiated).async {
            let url = PDFGenerator.generatePDF(from: images, fileName: fileName)

            DispatchQueue.main.async {
                isProcessing = false
                if url != nil {
                    savedFileName = fileName
                    showConfirmation = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
