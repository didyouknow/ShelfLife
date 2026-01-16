//
//  ViabilityView.swift
//  ShelfLife
//
//  Created by Garry Moyer on 4/7/25.
//

import SwiftUI
import Foundation

struct ViabilityView: View {
    @ObservedObject var viewModel = FoodInventoryViewModel()
    @State private var recipeSuggestions: String = ""
    @State private var isModelReady: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.getViableItems()) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(.headline)
                            Text("Expires in \(item.daysRemaining) day(s)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            // FreshnessBarView has been removed
                            // .frame(height: 10)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                    }

                    Divider()
                        .padding(.vertical)

                    if isModelReady {
                        Text("Recipe Recommendations")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)

                        Text(recipeSuggestions.isEmpty ? "Loading suggestions..." : recipeSuggestions)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .onAppear {
                                generateRecipeSuggestions()
                            }
                    } else {
                        Text("AI model not ready yet. Please wait...")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Viability")
            .onAppear {
                isModelReady = true // Set this when the model is confirmed loaded
            }
        }
    }

    func generateRecipeSuggestions() {
        let ingredients = viewModel.getViableItems().map { $0.name }.joined(separator: ", ")
        if ingredients.isEmpty {
            recipeSuggestions = "No viable items available. Add some foods to get suggestions."
            return
        }
        // Stubbed fallback suggestions (no model dependency)
        recipeSuggestions = """
        • Simple stir-fry with \(ingredients)
        • Omelet or frittata using \(ingredients)
        • Soup or salad featuring \(ingredients)
        """
    }
}

