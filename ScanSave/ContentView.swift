import SwiftUI

struct ContentView: View {
    @State private var showingScanner = false
    @State private var scannedImages: [UIImage] = []
    @State private var isSaving = false
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if scannedImages.isEmpty {
                    emptyStateView
                } else {
                    scannedImagesPreview
                }

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    if !scannedImages.isEmpty {
                        Button(action: { showingScanner = true }) {
                            Label("Scan More", systemImage: "plus.viewfinder")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                        Button(action: saveAndSharePDF) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Label("Save as PDF", systemImage: "doc.badge.arrow.down")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(isSaving)

                        Button(role: .destructive, action: clearScans) {
                            Label("Clear All", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(isSaving)
                    } else {
                        Button(action: { showingScanner = true }) {
                            Label("Scan Document", systemImage: "doc.viewfinder")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("ScanSave")
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView(scannedImages: $scannedImages)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = pdfURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.viewfinder")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)
                .padding(.top, 60)

            Text("No Scans Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap \"Scan Document\" to scan your first document.\nPDFs are named S-24_YYYY-MM-DD.pdf")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var scannedImagesPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(scannedImages.indices, id: \.self) { index in
                    Image(uiImage: scannedImages[index])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                        .overlay(alignment: .topTrailing) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .padding(8)
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private var pdfFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        return "S-24_\(dateString).pdf"
    }

    private var pdfFileURL: URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first!
        return documentsDirectory.appendingPathComponent(pdfFileName)
    }

    private func saveAndSharePDF() {
        guard !scannedImages.isEmpty else { return }
        isSaving = true

        DispatchQueue.global(qos: .userInitiated).async {
            PDFGenerator.generatePDF(
                from: scannedImages,
                fileName: pdfFileName
            )

            DispatchQueue.main.async {
                isSaving = false
                pdfURL = pdfFileURL
                showingShareSheet = true
            }
        }
    }

    private func clearScans() {
        withAnimation {
            scannedImages.removeAll()
        }
    }
}

// MARK: - Share Sheet Wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
