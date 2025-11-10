import SwiftUI
import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Lightweight chat models
struct ChatMessage: Identifiable, Equatable {
    enum Role { case user, assistant }
    let id = UUID()
    let role: Role
    let text: String
}

/// FoodAdvisorView
/// A chat-style advisor that uses Apple's on-device Foundation Models (iOS 26)
/// to suggest recipes and provide waste-reduction tips based on user-provided ingredients.
///
/// Notes for maintainers:
/// - This sample keeps chat history in-memory via @State. To persist across launches,
///   adopt SwiftData by creating a `@Model` type for ChatMessage and replacing @State
///   with `@Query` / `@Environment(\.modelContext)` as appropriate.
/// - To add inventory context, pass in a JSON list of current foods from your
///   FoodInventoryViewModel and prepend it to the prompt.
/// - This runs entirely on-device; do not add networking calls here.
struct FoodAdvisorView: View {

    // Custom initializer to support previews/tests by seeding @State
    init(messages: [ChatMessage] = []) {
        _messages = State(initialValue: messages)
    }

    // MARK: - State
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isGenerating: Bool = false

    // Auto-scroll anchor
    @State private var scrollID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            chatScroll
            Divider()
            inputBar
        }
        .navigationTitle("Food Advisor")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: messages) {
            // Nudge scroll when messages update
            scrollID = UUID()
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ask about your ingredients")
                    .font(.headline)
                Text("Get recipes and waste-reduction tips — powered by on-device Foundation Models.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
    }

    // MARK: - Chat list
    private var chatScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }
                    if isGenerating {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Thinking…")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .id(scrollID)
                    }
                }
                .padding(.vertical, 12)
            }
            .onChange(of: scrollID) { oldValue, newValue in
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo(newValue, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Input bar
    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("e.g. eggs, spinach, leftover rice", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...3)
            Button(action: { Task { await sendPrompt() } }) {
                Image(systemName: "paperplane.fill")
                    .imageScale(.medium)
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
        }
        .padding()
    }

    // MARK: - Bubble rendering
    @ViewBuilder
    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack(alignment: .bottom) {
            if message.role == .assistant { Spacer(minLength: 0) }
            VStack(alignment: .leading, spacing: 6) {
                Text(message.text)
                    .foregroundStyle(message.role == .user ? Color.white : Color.primary)
                    .font(.body)
            }
            .padding(12)
            .background(message.role == .user ? Color.accentColor : Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            if message.role == .user { Spacer(minLength: 0) }
        }
        .padding(.horizontal)
    }

    // MARK: - Model call
    @MainActor
    private func sendPrompt() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isGenerating else { return }

        // Append user's message locally first
        messages.append(ChatMessage(role: .user, text: trimmed))
        inputText = ""
        isGenerating = true

        // Compose a concise system instruction
        let systemInstruction = """
        You are FoodAdvisor, an on-device assistant for a food-spoilage manager app.
        Given user ingredients, respond with:
        1) A few concise recipe suggestions tailored to the ingredients.
        2) Practical tips to reduce waste (storage, reuse, or preparation ideas for near-expired foods).
        Keep responses short, actionable, and safe. Do not use the network.
        """

#if canImport(FoundationModels)
        do {
            // Attempt to use FoundationModels if present. The concrete API may differ across SDKs,
            // so we keep this call minimal and fall back gracefully if unavailable.
            // If your SDK provides a concrete entry point, replace the placeholder below.

            // Placeholder synchronous generation using a hypothetical global `FoundationModels.generate` API.
            // Replace this with the correct API for your environment.
            let prompt = """
            System:\n\(systemInstruction)\n\nUser:\n\(trimmed)
            """

            // Updated safer reflection usage:
            let reply: String
            if let generatorClass: AnyClass = NSClassFromString("FoundationModels.Generator") {
                let generateSelector = NSSelectorFromString("generateText:")

                // Attempt to call a class method `+generateText:` if it exists
                if (generatorClass as AnyObject).responds(to: generateSelector) {
                    if let unmanaged = (generatorClass as AnyObject).perform(generateSelector, with: prompt) {
                        let value = unmanaged.takeUnretainedValue()
                        if let result = value as? String {
                            reply = result
                        } else {
                            throw NSError(domain: "FoodAdvisorView", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unexpected return type from FoundationModels.Generator.generateText:"])
                        }
                    } else {
                        throw NSError(domain: "FoodAdvisorView", code: -1, userInfo: [NSLocalizedDescriptionKey: "FoundationModels API not available in this SDK."])
                    }
                } else if let nsObjectType = generatorClass as? NSObject.Type {
                    // Fallback: try creating an instance and calling an instance method `-generateText:`
                    let instance = nsObjectType.init()
                    if instance.responds(to: generateSelector),
                       let unmanaged = instance.perform(generateSelector, with: prompt) {
                        // perform returns Unmanaged<AnyObject>!; extract without optional chaining
                        let value = unmanaged.takeUnretainedValue()
                        if let result = value as? String {
                            reply = result
                        } else {
                            throw NSError(domain: "FoodAdvisorView", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unexpected return type from FoundationModels.Generator.generateText:"])
                        }
                    } else {
                        throw NSError(domain: "FoodAdvisorView", code: -1, userInfo: [NSLocalizedDescriptionKey: "FoundationModels API not available in this SDK."])
                    }
                } else {
                    throw NSError(domain: "FoodAdvisorView", code: -1, userInfo: [NSLocalizedDescriptionKey: "FoundationModels API not available in this SDK."])
                }
            } else {
                throw NSError(domain: "FoodAdvisorView", code: -1, userInfo: [NSLocalizedDescriptionKey: "FoundationModels API not available in this SDK."])
            }

            messages.append(ChatMessage(role: .assistant, text: reply))
        } catch {
            // Graceful fallback on error
            messages.append(ChatMessage(
                role: .assistant,
                text: "I couldn't generate suggestions right now. Try rephrasing your ingredients or asking again. (Error: \(error.localizedDescription))"
            ))
        }
#else
        // Fallback when FoundationModels isn't available (e.g., earlier SDKs or previews)
        messages.append(ChatMessage(
            role: .assistant,
            text: "Sample reply (offline preview):\n• Spinach & Egg Omelet\n• Fried rice with leftover rice and mixed veggies\n\nWaste-reduction: Store herbs wrapped in damp towels; freeze unused stock; make a frittata with scraps."
        ))
#endif

        isGenerating = false
    }
}

// MARK: - Preview
#Preview("FoodAdvisorView") {
    NavigationView {
        FoodAdvisorView(
            messages: [
                ChatMessage(role: .assistant, text: "Hi! Tell me what ingredients you have."),
                ChatMessage(role: .user, text: "eggs, spinach, leftover rice")
            ]
        )
    }
}

