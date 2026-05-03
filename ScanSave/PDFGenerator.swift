import UIKit
import PDFKit

struct PDFGenerator {

    /// Generates a PDF from an array of images and saves it to the app's Documents directory.
    /// - Parameters:
    ///   - images: The scanned images to include in the PDF.
    ///   - fileName: The name of the file (e.g. "S-24_2026-05-03.pdf").
    /// - Returns: `true` if the PDF was saved successfully, `false` otherwise.
    @discardableResult
    static func generatePDF(from images: [UIImage], fileName: String) -> Bool {
        let pdfDocument = PDFDocument()

        for (index, image) in images.enumerated() {
            // Create a PDF page from the image
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: index)
        }

        // Construct the file URL
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        // Write the PDF to disk
        let data = pdfDocument.dataRepresentation()
        do {
            try data?.write(to: fileURL)
            print("PDF saved to: \(fileURL.path)")
            return true
        } catch {
            print("Failed to save PDF: \(error.localizedDescription)")
            return false
        }
    }
}
