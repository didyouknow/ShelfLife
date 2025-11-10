//
//  BarcodeReaderView.swift
//  ShelfLife
//
//  Created by Garry Moyer on 4/9/25.
//

import SwiftUI
import VisionKit
import UIKit
import AudioToolbox

struct BarcodeReaderView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var hasScanned = false

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            onScan: onScan,
            dismiss: { presentationMode.wrappedValue.dismiss() },
            hasScanned: $hasScanned
        )
    }

    func makeUIViewController(context: Context) -> UIViewController {
        guard DataScannerViewController.isSupported && DataScannerViewController.isAvailable else {
            let fallbackVC = UIViewController()
            fallbackVC.view.backgroundColor = UIColor.systemBackground
            let label = UILabel()
            label.text = "Camera not available or not supported on this device."
            label.textAlignment = .center
            fallbackVC.view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: fallbackVC.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: fallbackVC.view.centerYAnchor)
            ])
            return fallbackVC
        }

        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )

        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var onScan: (String) -> Void
        var dismiss: () -> Void
        @Binding var hasScanned: Bool

        init(onScan: @escaping (String) -> Void, dismiss: @escaping () -> Void, hasScanned: Binding<Bool>) {
            self.onScan = onScan
            self.dismiss = dismiss
            self._hasScanned = hasScanned
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            guard !hasScanned else { return }
            hasScanned = true

            if case let .barcode(barcode) = item, let payload = barcode.payloadStringValue {
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                // API call placeholder
                fetchProductInfo(for: payload)

                onScan(payload)
                dismiss()
            }
        }

        func fetchProductInfo(for barcode: String) {
            guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else { return }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("API error:", error?.localizedDescription ?? "Unknown error")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let product = json["product"] as? [String: Any],
                       let productName = product["product_name"] as? String {
                        print("Product name:", productName)

                        // TODO: Hook these into actual UI elements in AddItemView
                        let brand = product["brands"] as? String ?? "Unknown"
                        let quantity = product["quantity"] as? String ?? "Unknown"
                        let imageUrl = product["image_url"] as? String ?? ""
                        let expiration = product["expiration_date"] as? String ?? "Unknown"
                        let nutrients = product["nutriments"] as? [String: Any] ?? [:]
                        print("Brand: \(brand)")
                        print("Quantity: \(quantity)")
                        print("Image URL: \(imageUrl)")
                        print("Expiration: \(expiration)")
                        print("Nutrients: \(nutrients)")
                    } else {
                        print("No product found for barcode: \(barcode)")
                        DispatchQueue.main.async {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.warning)
                        }
                    }
                } catch {
                    print("Failed to parse response:", error)
                }
            }

            task.resume()
        }
    }
    
    typealias UIViewControllerType = UIViewController
}

extension NSObject {
    func apply(_ configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}
