import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack(spacing: 0) {

            HStack(spacing: 10) {
                Image(systemName: "headphones")
                    .font(.title3)
                Text("Mood Müzik Asistanı")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))

            if let err = viewModel.errorText {
                Text(err)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(Color(.systemGray6))
            }

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            messageRow(message)
                                .id(message.id)
                        }

                        if viewModel.isLoading {
                            messageRow(.init(role: .bot, text: "Yazıyor…"))
                                .id("typing")
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastID = viewModel.messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isLoading) { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }

            Divider()

            // Input
            HStack(spacing: 10) {
                TextField("Bugün nasıl hissediyorsun? Örn: mutsuz, enerjik...", text: $viewModel.input)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { viewModel.send() }

                Button {
                    viewModel.send()
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private func messageRow(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == .bot {
                bubble(message.text, isUser: false)
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                bubble(message.text, isUser: true)
            }
        }
    }

    private func bubble(_ text: String, isUser: Bool) -> some View {
        Text(text)
            .font(.body)
            .padding(12)
            .foregroundColor(isUser ? .white : .primary)
            .background(isUser ? Color.blue : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ContentView()
}
