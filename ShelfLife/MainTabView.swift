//
//  MainTabView.swift
//  ShelfLife
//
//  Created by Garry Moyer on 4/7/25.
//

import SwiftUI


struct MainTabView: View {
    @StateObject private var viewModel = FoodInventoryViewModel()

    var body: some View {
        TabView {
            InventoryListView(viewModel: viewModel)
                .tabItem {
                    Label("All Items", systemImage: "list.bullet")
                }

            ViabilityView(viewModel: viewModel)
                .tabItem {
                    Label("Viability", systemImage: "hourglass")
                }

            FavoritesView(viewModel: viewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }

            TrashPileView(viewModel: viewModel)
                .tabItem {
                    Label("Trash", systemImage: "trash")
                }
        }
    }
}
