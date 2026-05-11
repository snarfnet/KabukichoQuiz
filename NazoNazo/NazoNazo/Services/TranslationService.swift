import Foundation
import Translation

@MainActor
@available(iOS 18.0, *)
class TranslationService {
    private var session: TranslationSession?

    func translate(_ text: String) async -> String {
        guard !text.isEmpty else { return text }

        do {
            if session == nil {
                let source = Locale.Language(identifier: "en")
                let target = Locale.Language(identifier: "ja")
                if #available(iOS 26.0, *) {
                    session = try await TranslationSession(installedSource: source, target: target)
                } else {
                    let config = TranslationSession.Configuration(source: source, target: target)
                    session = try await TranslationSession(configuration: config)
                }
            }
            let response = try await session!.translate(text)
            return response.targetText
        } catch {
            return text
        }
    }
}

@MainActor
class TranslationServiceWrapper {
    private var service: Any?

    init() {
        if #available(iOS 18.0, *) {
            service = TranslationService()
        }
    }

    func translate(_ text: String) async -> String {
        if #available(iOS 18.0, *), let svc = service as? TranslationService {
            return await svc.translate(text)
        }
        return text
    }
}
