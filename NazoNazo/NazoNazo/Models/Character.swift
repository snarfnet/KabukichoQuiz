import Foundation

enum Difficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var apiValue: String { rawValue }

    var questionsPerRound: Int { 10 }
}

struct GameCharacter: Identifiable {
    let id = UUID()
    let name: String
    let difficulty: Difficulty
    let imageName: String
    let greeting: String
    let correctResponse: String
    let wrongResponse: String
    let clearResponse: String

    static let allCharacters: [GameCharacter] = [
        GameCharacter(
            name: "りりあ",
            difficulty: .easy,
            imageName: "easy_character",
            greeting: "ゆっくりで大丈夫だよ。まずはこの問題からね。",
            correctResponse: "えらい、ちゃんと見てたんだね。",
            wrongResponse: "惜しいね。次は一緒に当てよ？",
            clearResponse: "すごい！全部できたね。次の子に会ってみる？"
        ),
        GameCharacter(
            name: "みれい",
            difficulty: .medium,
            imageName: "medium_character",
            greeting: "これくらい、当然わかるよね？",
            correctResponse: "ふーん。まあ、悪くないじゃん。",
            wrongResponse: "ちょっと。今のは落としちゃダメでしょ。",
            clearResponse: "認めてあげる。次はもっと手強いから。"
        ),
        GameCharacter(
            name: "ねむ",
            difficulty: .hard,
            imageName: "hard_character",
            greeting: "逃げないで。最後まで答えて。",
            correctResponse: "やっぱり、あなたなら覚えてくれると思ってた。",
            wrongResponse: "忘れたの？ 私は覚えてるのに。",
            clearResponse: "全部正解...ずっと一緒にいてくれるよね？"
        ),
    ]

    static func character(for difficulty: Difficulty) -> GameCharacter {
        allCharacters.first { $0.difficulty == difficulty }!
    }
}
