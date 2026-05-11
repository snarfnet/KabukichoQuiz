import Foundation

class TriviaService {
    private let baseURL = "https://opentdb.com/api.php"
    private var sessionToken: String?

    func fetchQuestions(amount: Int, difficulty: Difficulty) async throws -> [TriviaQuestion] {
        if sessionToken == nil {
            sessionToken = try await fetchSessionToken()
        }

        var components = URLComponents(string: baseURL)!
        var queryItems = [
            URLQueryItem(name: "amount", value: "\(amount)"),
            URLQueryItem(name: "difficulty", value: difficulty.apiValue),
            URLQueryItem(name: "type", value: "multiple"),
        ]
        if let token = sessionToken {
            queryItems.append(URLQueryItem(name: "token", value: token))
        }
        components.queryItems = queryItems

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(TriviaResponse.self, from: data)

        if response.responseCode == 3 || response.responseCode == 4 {
            sessionToken = try await fetchSessionToken()
            return try await fetchQuestions(amount: amount, difficulty: difficulty)
        }

        return response.results
    }

    private func fetchSessionToken() async throws -> String {
        let url = URL(string: "https://opentdb.com/api_token.php?command=request")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["token"] as? String ?? ""
    }
}
