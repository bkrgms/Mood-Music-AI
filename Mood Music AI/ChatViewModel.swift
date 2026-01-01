import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var messages: [ChatMessage] = [
        ChatMessage(role: .bot, text: "Merhaba! 🎧 Nasıl hissediyorsun? Ruh haline göre Türkçe şarkılar önerebilirim.")
    ]
    @Published var isLoading: Bool = false
    @Published var errorText: String?

    private let service = ChatService()

    func onAppear() {
        Task {
            do {
                _ = try await service.health()
            } catch {
                errorText = "Sunucuya bağlanılamadı: \(error.localizedDescription)"
            }
        }
    }

    func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        messages.append(ChatMessage(role: .user, text: text))
        input = ""
        isLoading = true
        errorText = nil

        Task {
            do {
                let res = try await service.send(message: text)
                messages.append(ChatMessage(role: .bot, text: res.reply))
            } catch {
                errorText = error.localizedDescription
                messages.append(ChatMessage(role: .bot, text: "Bağlantı hatası: \(error.localizedDescription)"))
            }
            isLoading = false
        }
    }
}
