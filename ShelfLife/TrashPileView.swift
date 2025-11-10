//
//  TrashPileView.swift
//  ShelfLife
//
//  Created by Garry Moyer on 4/7/25.
//

import SwiftUI

struct TrashStats {
    var totalItems: Int
    var usedBeforeExpired: Int
    var expired: Int

    var savedPercentage: Double {
        guard totalItems > 0 else { return 0 }
        return Double(usedBeforeExpired) / Double(totalItems)
    }

    var trashLevel: Int {
        switch savedPercentage {
        case 0.8...: return 0    // Clean bin
        case 0.6..<0.8: return 1
        case 0.4..<0.6: return 2
        case 0.2..<0.4: return 3
        default: return 4        // Full bin
        }
    }
}

struct TrashPileView: View {
    @ObservedObject var viewModel: FoodInventoryViewModel

    var stats: TrashStats {
        let total = viewModel.items.count
        let used = viewModel.items.filter { $0.isUsed && $0.daysRemaining >= 0 }.count
        let expired = viewModel.items.filter { !$0.isUsed && $0.daysRemaining < 0 }.count
        return TrashStats(totalItems: total, usedBeforeExpired: used, expired: expired)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Trash Level: \(stats.trashLevel)")
                .font(.title)
                .bold()

            Image("trash_level_\(stats.trashLevel)")
                .resizable()
                .scaledToFit()
                .frame(height: 200)

            Text("You've saved \(Int(stats.savedPercentage * 100))% of your food!")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Your Trash Pile")
    }
}
