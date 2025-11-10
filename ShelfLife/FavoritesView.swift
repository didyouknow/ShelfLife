//
//  FavoritesView.swift
//  ShelfLife
//
//  Created by Garry Moyer on 4/7/25.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel = FoodInventoryViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.foodItems.filter { $0.isFavorite }) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.headline)
                    Text("Expires in \(item.daysRemaining) day(s)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ProgressView(value: item.freshnessPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: item.freshnessColor))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Favorites")
        }
    }
}
