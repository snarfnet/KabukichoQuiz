import SwiftUI

struct QuizView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            Image("background_quiz")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.3)
                .ignoresSafeArea()

            if gameManager.isLoading {
                LoadingView()
            } else if gameManager.showResult {
                ResultView()
            } else if let question = gameManager.currentQuestion {
                QuestionView(question: question)
            }
        }
    }
}

struct LoadingView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var dots = ""
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Image(gameManager.currentCharacter.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 168)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("問題を準備中\(dots)")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)

            ProgressView()
                .tint(.pink)
                .scaleEffect(1.5)
        }
        .onReceive(timer) { _ in
            dots = dots.count >= 3 ? "" : dots + "."
        }
    }
}

struct QuestionView: View {
    @EnvironmentObject var gameManager: GameManager
    let question: Question

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { gameManager.goHome() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Text("\(gameManager.currentQuestionIndex + 1) / \(gameManager.questions.count)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Text("正解: \(gameManager.score)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.pink)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * gameManager.progress, height: 6)
                        .animation(.easeInOut, value: gameManager.progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Character + speech bubble
            HStack(alignment: .bottom, spacing: 12) {
                Image(gameManager.currentCharacter.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 98)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                if gameManager.isAnswered {
                    let isCorrect = gameManager.selectedAnswer?.isCorrect ?? false
                    Text(isCorrect
                         ? gameManager.currentCharacter.correctResponse
                         : gameManager.currentCharacter.wrongResponse)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                        )
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Question text
            Text(question.text)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)

            // Answer buttons
            VStack(spacing: 12) {
                ForEach(question.answers) { answer in
                    AnswerButton(
                        answer: answer,
                        isSelected: gameManager.selectedAnswer?.id == answer.id,
                        isAnswered: gameManager.isAnswered
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            gameManager.selectAnswer(answer)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)

            Spacer()

            // Next button
            if gameManager.isAnswered {
                Button(action: {
                    withAnimation {
                        gameManager.nextQuestion()
                    }
                }) {
                    HStack {
                        Text(gameManager.currentQuestionIndex + 1 >= gameManager.questions.count
                             ? "結果を見る" : "次の問題")
                            .font(.system(size: 16, weight: .bold))

                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .pink.opacity(0.4), radius: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

struct AnswerButton: View {
    let answer: Answer
    let isSelected: Bool
    let isAnswered: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(answer.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isAnswered {
                    Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : ""))
                        .foregroundColor(answer.isCorrect ? .green : .red)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .disabled(isAnswered)
    }

    private var backgroundColor: Color {
        if !isAnswered {
            return Color.white.opacity(isSelected ? 0.15 : 0.08)
        }
        if answer.isCorrect {
            return Color.green.opacity(0.2)
        }
        if isSelected && !answer.isCorrect {
            return Color.red.opacity(0.2)
        }
        return Color.white.opacity(0.05)
    }

    private var borderColor: Color {
        if !isAnswered {
            return Color.purple.opacity(isSelected ? 0.8 : 0.3)
        }
        if answer.isCorrect {
            return Color.green.opacity(0.6)
        }
        if isSelected && !answer.isCorrect {
            return Color.red.opacity(0.6)
        }
        return Color.white.opacity(0.1)
    }
}
