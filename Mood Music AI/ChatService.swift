import Foundation

enum APIError: Error, LocalizedError {
    case badURL
    case http(Int, String)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .badURL: return "Geçersiz URL"
        case .http(let code, let body): return "Sunucu hatası (\(code)): \(body)"
        case .decoding(let msg): return "Veri çözümlenemedi: \(msg)"
        }
    }
}

final class ChatService {
    
    private let baseURL = "https://kelsie-hostless-toilfully.ngrok-free.dev"

    private var base: URL {
        get throws {
            guard let url = URL(string: baseURL) else { throw APIError.badURL }
            return url
        }
    }

    func health() async throws -> Bool {
        let url = try base.appendingPathComponent("health")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 20

        let (data, resp) = try await URLSession.shared.data(for: req)

        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        return true
    }

    func send(message: String) async throws -> ChatResponse {
        let url = try base.appendingPathComponent("chat")

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 60
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ChatRequest(message: message)
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, resp) = try await URLSession.shared.data(for: req)

        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }

        do {
            return try JSONDecoder().decode(ChatResponse.self, from: data)
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw APIError.decoding("\(error.localizedDescription)\nRaw: \(raw)")
        }
    }
}
