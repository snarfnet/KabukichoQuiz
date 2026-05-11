import Foundation
import Translation

@MainActor
class TranslationService {
    private var session: TranslationSession?

    func translate(_ text: String) async -> String {
        guard !text.isEmpty else { return text }

        if #available(iOS 26.0, *) {
            do {
                if session == nil {
                    session = try await TranslationSession(
                        installedSource: Locale.Language(identifier: "en"),
                        target: Locale.Language(identifier: "ja")
                    )
                }
                let response = try await session!.translate(text)
                return response.targetText
            } catch {
                return text
            }
        }
        return text
    }
}
