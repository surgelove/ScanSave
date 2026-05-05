import UIKit
import PDFKit
import os

/// Generates PDF documents from scanned images.
enum PDFGenerator {

    /// Generates a PDF from an array of images and writes it to the app's Documents directory.
    ///
    /// - Parameters:
    ///   - images: The scanned images to include in the PDF.
    ///   - fileName: The desired file name (e.g. `"S-24 2026-05-03.pdf"`).
    /// - Returns: The file `URL` if the PDF was written successfully, or `nil` on failure.
    @discardableResult
    static func generatePDF(from images: [UIImage], fileName: String) -> URL? {
        let pdfDocument = PDFDocument()

        for (index, image) in images.enumerated() {
            guard let pdfPage = PDFPage(image: image) else {
                Logger().warning("Skipped page \(index) — could not create PDFPage from image.")
                continue
            }
            pdfDocument.insert(pdfPage, at: index)
        }

        guard pdfDocument.pageCount > 0 else {
            Logger().error("No pages were added to the PDF document.")
            return nil
        }

        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first

        guard let documentsDirectory else {
            Logger().error("Could not access the Documents directory.")
            return nil
        }

        let fileURL = uniqueFileURL(for: documentsDirectory.appendingPathComponent(fileName))

        guard let data = pdfDocument.dataRepresentation() else {
            Logger().error("Could not obtain PDF data representation.")
            return nil
        }

        do {
            try data.write(to: fileURL)
            Logger().info("PDF saved to \(fileURL.path)")
            return fileURL
        } catch {
            Logger().error("Failed to save PDF: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - File Conflict Resolution

extension PDFGenerator {
    /// If a file already exists at the given URL, returns a new URL with `_1`, `_2`, etc.
    /// appended before the file extension so existing files are never overwritten.
    fileprivate static func uniqueFileURL(for url: URL) -> URL {
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else { return url }

        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        let dir = url.deletingLastPathComponent()

        var counter = 1
        while true {
            let candidate = dir.appendingPathComponent("\(base)_\(counter).\(ext)")
            if !fm.fileExists(atPath: candidate.path) {
                return candidate
            }
            counter += 1
        }
    }
}

// MARK: - Convenience Logger

extension Logger {
    fileprivate static let subsystem = Bundle.main.bundleIdentifier ?? "com.simplyscan"

    init(category: String = "PDFGenerator") {
        self.init(subsystem: Self.subsystem, category: category)
    }
}
