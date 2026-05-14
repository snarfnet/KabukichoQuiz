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

            Group {
                if gameManager.isLoading {
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if gameManager.showResult {
                    ResultView()
                } else if let question = gameManager.currentQuestion {
                    QuestionView(question: question)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BannerAdView()
                .frame(height: 50)
                .background(Color.black.opacity(0.35))
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
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            ProgressView()
                .tint(.pink)
                .scaleEffect(1.5)
        }
        .padding(24)
        .onReceive(timer) { _ in
            dots = dots.count >= 3 ? "" : dots + "."
        }
    }
}

struct QuestionView: View {
    @EnvironmentObject var gameManager: GameManager
    let question: Question

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                progressBar
                characterRow
                questionText
                answers

                if gameManager.isAnswered {
                    nextButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        HStack {
            Button(action: { gameManager.goHome() }) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.75))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }

            Spacer()

            Text("\(gameManager.currentQuestionIndex + 1) / \(gameManager.questions.count)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.84))
                .lineLimit(1)

            Spacer()

            Text("正解: \(gameManager.score)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.pink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(minWidth: 64, alignment: .trailing)
        }
    }

    private var progressBar: some View {
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
    }

    private var characterRow: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Image(gameManager.currentCharacter.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 64, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if gameManager.isAnswered {
                let isCorrect = gameManager.selectedAnswer?.isCorrect ?? false
                Text(isCorrect
                     ? gameManager.currentCharacter.correctResponse
                     : gameManager.currentCharacter.wrongResponse)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.1))
                    )
                    .transition(.opacity)
            } else {
                Spacer(minLength: 0)
            }
        }
    }

    private var questionText: some View {
        Text(question.text)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
    }

    private var answers: some View {
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
    }

    private var nextButton: some View {
        Button(action: {
            withAnimation {
                gameManager.nextQuestion()
            }
        }) {
            HStack {
                Text(gameManager.currentQuestionIndex + 1 >= gameManager.questions.count
                     ? "結果を見る" : "次の問題")
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

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
        .padding(.horizontal, 8)
    }
}

struct AnswerButton: View {
    let answer: Answer
    let isSelected: Bool
    let isAnswered: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                Text(answer.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                if isAnswered {
                    if answer.isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
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
        .buttonStyle(.plain)
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
