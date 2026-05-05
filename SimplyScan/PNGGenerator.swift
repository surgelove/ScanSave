import UIKit
import os

/// Saves scanned images as PNG files.
enum PNGGenerator {

    /// Saves the first scanned image as a PNG file in the app's Documents directory.
    ///
    /// - Parameters:
    ///   - images: The scanned images. Only the first image is saved.
    ///   - fileName: The desired file name (e.g. `"S-24 2026-05-03.png"`).
    /// - Returns: The file `URL` if successful, or `nil` on failure.
    @discardableResult
    static func saveAsPNG(from images: [UIImage], fileName: String) -> URL? {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.simplyscan", category: "PNGGenerator")

        guard let firstImage = images.first else {
            logger.error("No images to save.")
            return nil
        }

        guard let data = firstImage.pngData() else {
            logger.error("Could not generate PNG data from image.")
            return nil
        }

        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first

        guard let documentsDirectory else {
            logger.error("Could not access the Documents directory.")
            return nil
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            logger.info("PNG saved to \(fileURL.path)")
            return fileURL
        } catch {
            logger.error("Failed to save PNG: \(error.localizedDescription)")
            return nil
        }
    }
}
