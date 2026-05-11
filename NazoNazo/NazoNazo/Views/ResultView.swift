import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(gameManager.currentCharacter.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 224)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: resultColor.opacity(0.5), radius: 12)

            Text(gameManager.currentCharacter.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            // Score
            VStack(spacing: 8) {
                Text("\(gameManager.score) / \(gameManager.questions.count)")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gameManager.isCleared ? [.pink, .purple] : [.gray, .white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: resultColor.opacity(0.6), radius: 8)

                Text(gameManager.isCleared ? "クリア！" : "もう一回...")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(resultColor)
            }

            // Character message
            Text(gameManager.isCleared
                 ? gameManager.currentCharacter.clearResponse
                 : gameManager.currentCharacter.wrongResponse)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 20)

            // Unlock message
            if gameManager.isCleared && gameManager.currentDifficulty != .hard {
                let nextChar = nextCharacterName
                Text("「\(nextChar)」が解放されました！")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.15))
                    )
            }

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                if !gameManager.isCleared {
                    Button(action: {
                        Task {
                            await gameManager.startQuiz(difficulty: gameManager.currentDifficulty)
                        }
                    }) {
                        Text("もう一回挑戦する")
                            .font(.system(size: 16, weight: .bold))
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
                }

                Button(action: { gameManager.goHome() }) {
                    Text("ホームに戻る")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var resultColor: Color {
        gameManager.isCleared ? .pink : .gray
    }

    private var nextCharacterName: String {
        switch gameManager.currentDifficulty {
        case .easy: return GameCharacter.character(for: .medium).name
        case .medium: return GameCharacter.character(for: .hard).name
        case .hard: return ""
        }
    }
}
