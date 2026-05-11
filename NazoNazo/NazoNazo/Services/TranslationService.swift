import Foundation
import Translation

@MainActor
class TranslationService {
    private var session: Any?

    func translate(_ text: String) async -> String {
        guard !text.isEmpty else { return text }

        if #available(iOS 26.0, *) {
            do {
                if session == nil {
                    let s = try await TranslationSession(
                        installedSource: Locale.Language(identifier: "en"),
                        target: Locale.Language(identifier: "ja")
                    )
                    session = s
                }
                let s = session as! TranslationSession
                let response = try await s.translate(text)
                return response.targetText
            } catch {
                return text
            }
        }
        return text
    }
}
