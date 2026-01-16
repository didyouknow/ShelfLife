import SwiftUI

class FoodInventoryViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []

    var items: [FoodItem] {
        return foodItems
    }

    // Load food items function, it can fetch from database, API, or local storage
    func loadFoodItems() {
        // Add logic for loading items
    }

    // Get viable food items (those still fresh)
    func getViableItems() -> [FoodItem] {
        return foodItems.filter { $0.daysRemaining > 0 }
    }

    // Calculate freshness for a food item
    func calculateFreshness(for item: FoodItem) -> Double {
        // Logic for calculating freshness (for example, as a percentage)
        return Double(item.daysRemaining) / 100.0
    }
    
    // Toggle favorite status for a food item
    func toggleFavorite(id: UUID) {
        if let index = foodItems.firstIndex(where: { $0.id == id }) {
            foodItems[index].isFavorite.toggle()
        }
    }
}
