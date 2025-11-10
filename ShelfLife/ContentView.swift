import SwiftUI
import CoreML

struct ContentView: View {
    @State private var promptText: String = "I have eggs and spinach. What should I make?"
    @State private var resultText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter ingredients...", text: $promptText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Ask Llama") {
                do {
                    let config = MLModelConfiguration()
                    let model = try TinyLLaMA(configuration: config)

                    let tokens: [Float] = [1, 306, 505, 29808, 322, 10917, 496, 29889, 1724, 881, 306, 1207, 29973]
                    let inputArray = try MLMultiArray(shape: [1, NSNumber(value: tokens.count)], dataType: .float32)

                    for (i, token) in tokens.enumerated() {
                        inputArray[i] = NSNumber(value: token)
                    }

                    let prediction = try model.prediction(input_ids: inputArray)
                    resultText = "Model ran. Output shape: \(prediction.var_3447ShapedArray.shape)"
                } catch {
                    resultText = "Error: \(error.localizedDescription)"
                }
            }

            Text(resultText)
                .padding()
                .foregroundColor(.green)
            
            Divider()
            Text("Chat with AI:")
                .font(.headline)
            TextEditor(text: $resultText)
                .frame(height: 100)
                .border(Color.gray)

            Divider()
            Text("Suggestions")
                .font(.headline)
            VStack(alignment: .leading) {
                Text("• Spinach omelet")
                Text("• Egg fried rice")
                Text("• Creamed spinach")
            }
        }
        .padding()
    }
}
