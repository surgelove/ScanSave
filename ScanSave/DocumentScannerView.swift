import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    let onScan: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(
        _ uiViewController: VNDocumentCameraViewController,
        context: Context
    ) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView

        init(parent: DocumentScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            var images: [UIImage] = []
            for pageIndex in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: pageIndex))
            }
            parent.onScan(images)
            parent.dismiss()
        }

        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            parent.dismiss()
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            print("Document scan failed: \(error.localizedDescription)")
            parent.dismiss()
        }
    }
}
