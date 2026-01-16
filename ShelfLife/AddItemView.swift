import SwiftUI
import VisionKit
import Foundation
import Combine

// View for adding a new food item into the inventory
struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss // Controls dismissing the modal
    @ObservedObject var viewModel: FoodInventoryViewModel // Shared inventory data model

    // Form input fields
    @State private var name: String = "" // Name of the item
    @State private var purchaseDate: Date = Date() // Date of purchase
    @State private var shelfLifeDays: String = "" // Shelf life in days
    @State private var isShowingScanner = false // Controls whether barcode scanner sheet is shown
    @State private var brand: String = "" // Brand of the item
    @State private var quantity: String = "" // Quantity of the item
    @State private var imageUrl: String = "" // Placeholder for future image handling
    @State private var expiration: String = "" // Auto-filled expiration from barcode scan

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    TextField("Shelf Life (days)", text: $shelfLifeDays)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numberPad)

                    TextField("Brand", text: $brand)
                    TextField("Quantity", text: $quantity)
                        .textInputAutocapitalization(.never)

                    if !expiration.isEmpty {
                        Text("Expiration Date (from barcode): \(expiration)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        isShowingScanner = true
                    }) {
                        Label("Scan Barcode", systemImage: "barcode.viewfinder")
                    }
                    .sheet(isPresented: $isShowingScanner) {
                        self.barcodeScannerSheet
                    }
                } header: {
                    Text("Item Details")
                }

                Section {
                    Button("Add Item") {
                        if let days = Int(shelfLifeDays), !name.isEmpty {
                            self.viewModel.foodItems.append(FoodItem(
                                name: name,
                                purchaseDate: purchaseDate,
                                shelfLifeDays: days,
                                isFavorite: false,
                                isUsed: false,
                                daysRemaining: days,
                                freshnessPercentage: 1.0,
                                freshnessColor: Color.green
                            ))
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || Int(shelfLifeDays) == nil)
                }

                if let days = Int(shelfLifeDays), days > 0 {
                    VStack(alignment: .leading) {
                        Text("Freshness Preview")
                            .font(.caption)
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green.opacity(0.8))
                                .frame(width: geo.size.width * 1.0, height: 10)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1))
                        }
                        .frame(height: 10)
                    }
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // Barcode scanning overlay logic (VisionKit)
    private var barcodeScannerSheet: some View {
        BarcodeReaderView { scannedCode in
            self.name = scannedCode // Assign scanned value as name
        }
    }
}
