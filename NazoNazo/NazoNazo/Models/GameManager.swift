import Foundation
import SwiftUI

@MainActor
class GameManager: ObservableObject {
    @Published var currentDifficulty: Difficulty = .easy
    @Published var unlockedDifficulties: Set<Difficulty> = [.easy]
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var isLoading = false
    @Published var showResult = false
    @Published var selectedAnswer: Answer?
    @Published var isAnswered = false
    @Published var gamePhase: GamePhase = .home

    private let triviaService = TriviaService()
    private let translationService = TranslationService()

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var currentCharacter: GameCharacter {
        GameCharacter.character(for: currentDifficulty)
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }

    var isCleared: Bool {
        let threshold = questions.count / 2 + 1
        return score >= threshold
    }

    func startQuiz(difficulty: Difficulty) async {
        currentDifficulty = difficulty
        currentQuestionIndex = 0
        score = 0
        showResult = false
        selectedAnswer = nil
        isAnswered = false
        isLoading = true
        gamePhase = .quiz

        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            questions = Self.mockQuestions
        } else {
            do {
                let triviaQuestions = try await triviaService.fetchQuestions(
                    amount: difficulty.questionsPerRound,
                    difficulty: difficulty
                )
                questions = await translateQuestions(triviaQuestions)
            } catch {
                questions = []
            }
        }

        isLoading = false
    }

    static let mockQuestions: [Question] = [
        Question(text: "太陽系で最も大きい惑星はどれ？", answers: [
            Answer(text: "木星", isCorrect: true),
            Answer(text: "土星", isCorrect: false),
            Answer(text: "海王星", isCorrect: false),
            Answer(text: "天王星", isCorrect: false),
        ], correctIndex: 0),
        Question(text: "日本で一番高い山は？", answers: [
            Answer(text: "北岳", isCorrect: false),
            Answer(text: "富士山", isCorrect: true),
            Answer(text: "槍ヶ岳", isCorrect: false),
            Answer(text: "奥穂高岳", isCorrect: false),
        ], correctIndex: 1),
    ]

    func selectAnswer(_ answer: Answer) {
        guard !isAnswered else { return }
        selectedAnswer = answer
        isAnswered = true
        if answer.isCorrect {
            score += 1
        }
    }

    func nextQuestion() {
        if currentQuestionIndex + 1 >= questions.count {
            showResult = true
            if isCleared {
                unlockNext()
            }
        } else {
            currentQuestionIndex += 1
            selectedAnswer = nil
            isAnswered = false
        }
    }

    func goHome() {
        gamePhase = .home
        questions = []
        currentQuestionIndex = 0
        score = 0
        showResult = false
        selectedAnswer = nil
        isAnswered = false
    }

    private func unlockNext() {
        switch currentDifficulty {
        case .easy:
            unlockedDifficulties.insert(.medium)
        case .medium:
            unlockedDifficulties.insert(.hard)
        case .hard:
            break
        }
    }

    private func translateQuestions(_ triviaQuestions: [TriviaQuestion]) async -> [Question] {
        var result: [Question] = []

        for tq in triviaQuestions {
            let decodedQuestion = tq.question.htmlDecoded
            let decodedCorrect = tq.correctAnswer.htmlDecoded
            let decodedIncorrect = tq.incorrectAnswers.map { $0.htmlDecoded }

            let translatedQuestion = await translationService.translate(decodedQuestion)
            let translatedCorrect = await translationService.translate(decodedCorrect)
            var translatedIncorrect: [String] = []
            for incorrect in decodedIncorrect {
                let t = await translationService.translate(incorrect)
                translatedIncorrect.append(t)
            }

            var allAnswers = translatedIncorrect.map { Answer(text: $0, isCorrect: false) }
            let correctAnswer = Answer(text: translatedCorrect, isCorrect: true)
            let insertIndex = Int.random(in: 0...allAnswers.count)
            allAnswers.insert(correctAnswer, at: insertIndex)

            let question = Question(
                text: translatedQuestion,
                answers: allAnswers,
                correctIndex: insertIndex
            )
            result.append(question)
        }

        return result
    }
}

enum GamePhase {
    case home
    case quiz
}

extension String {
    var htmlDecoded: String {
        let entities: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#039;": "'",
            "&apos;": "'",
            "&laquo;": "<<",
            "&raquo;": ">>",
            "&eacute;": "e",
            "&ouml;": "o",
            "&uuml;": "u",
            "&aring;": "a",
            "&ntilde;": "n",
        ]
        var result = self
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        return result
    }
}
