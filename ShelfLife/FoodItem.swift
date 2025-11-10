import SwiftUI

struct FoodItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var purchaseDate: Date
    var shelfLifeDays: Int
    var isFavorite: Bool
    var isUsed: Bool

    var daysRemaining: Int {
        let calendar = Calendar.current
        let expirationDate = calendar.date(byAdding: .day, value: shelfLifeDays, to: purchaseDate)!
        let remaining = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return remaining
    }

    var freshnessPercentage: Double {
        let total = Double(shelfLifeDays)
        let remaining = Double(daysRemaining)
        return max(0, min(1, remaining / total))
    }

    var freshnessColor: Color {
        switch freshnessPercentage {
        case 0.7...: return .green
        case 0.3..<0.7: return .yellow
        default: return .brown
        }
    }
}
