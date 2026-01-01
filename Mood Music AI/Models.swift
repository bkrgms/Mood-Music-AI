import Foundation

enum MessageRole: String, Codable {
    case user
    case bot
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), role: MessageRole, text: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

struct ChatRequest: Codable {
    let message: String
}

struct ChatResponse: Codable {
    let reply: String
}
