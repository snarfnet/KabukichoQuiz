import Foundation
import Translation

@MainActor
class TranslationService {
    private var session: TranslationSession?

    func translate(_ text: String) async -> String {
        guard !text.isEmpty else { return text }

        do {
            if session == nil {
                let config = TranslationSession.Configuration(
                    source: .init(identifier: "en"),
                    target: .init(identifier: "ja")
                )
                session = try await TranslationSession(configuration: config)
            }
            let response = try await session!.translate(text)
            return response.targetText
        } catch {
            return text
        }
    }
}
