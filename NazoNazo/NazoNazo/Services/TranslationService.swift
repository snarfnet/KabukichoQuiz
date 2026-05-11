import Foundation
import Translation

@MainActor
class TranslationService {
    private var session: TranslationSession?

    func translate(_ text: String) async -> String {
        guard !text.isEmpty else { return text }

        do {
            if session == nil {
                if #available(iOS 18.0, *) {
                    session = try await TranslationSession(
                        installedSource: Locale.Language(identifier: "en"),
                        target: Locale.Language(identifier: "ja")
                    )
                } else {
                    return text
                }
            }
            if #available(iOS 18.0, *) {
                let response = try await session!.translate(text)
                return response.targetText
            }
            return text
        } catch {
            return text
        }
    }
}
