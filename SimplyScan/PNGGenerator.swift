import UIKit
import os

// MARK: - File Conflict Resolution

extension PNGGenerator {
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

        let fileURL = uniqueFileURL(for: documentsDirectory.appendingPathComponent(fileName))

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
