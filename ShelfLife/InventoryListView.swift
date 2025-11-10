import SwiftUI

struct FreshnessBarView: View {
    let percentage: Double
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(percentage))
            }
            .frame(height: 10)
            .cornerRadius(4)
        }
        .frame(height: 10)
    }
}

struct InventoryListView: View {
    @ObservedObject var viewModel = FoodInventoryViewModel()
    @State private var showingAddItem = false

    var body: some View {
        NavigationView {
            List(viewModel.foodItems.filter { $0.isActive }, id: \.id) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name)
                            .font(.headline)
                        Text("Expires in \(item.daysRemaining) day(s)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        FreshnessBarView(percentage: item.freshnessPercentage, color: item.freshnessColor)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.toggleFavorite(id: item.id)
                    }) {
                        Image(systemName: item.isFavorite ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("ShelfLife")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddItem = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(viewModel: viewModel)
            }
        }
    }
}
