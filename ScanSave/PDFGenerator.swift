import UIKit
import PDFKit

struct PDFGenerator {

    /// Generates a PDF from an array of images and saves it to the app's Documents directory.
    /// - Parameters:
    ///   - images: The scanned images to include in the PDF.
    ///   - fileName: The name of the file (e.g. "S-24_2026-05-03.pdf").
    /// - Returns: The file URL if saved successfully, `nil` otherwise.
    @discardableResult
    static func generatePDF(from images: [UIImage], fileName: String) -> URL? {
        let pdfDocument = PDFDocument()

        for (index, image) in images.enumerated() {
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: index)
        }

        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        let data = pdfDocument.dataRepresentation()
        do {
            try data?.write(to: fileURL)
            print("PDF saved to: \(fileURL.path)")
            return fileURL
        } catch {
            print("Failed to save PDF: \(error.localizedDescription)")
            return nil
        }
    }
}
