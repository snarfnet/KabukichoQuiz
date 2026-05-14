import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameManager: GameManager
    @StateObject private var adManager = AdManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(gameManager.currentCharacter.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 196)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: resultColor.opacity(0.5), radius: 12)

                Text(gameManager.currentCharacter.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                scoreBlock
                characterMessage
                unlockMessage
                actionButtons
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                adManager.showInterstitialIfReady(from: rootVC)
            }
        }
    }

    private var scoreBlock: some View {
        VStack(spacing: 8) {
            Text("\(gameManager.score) / \(gameManager.questions.count)")
                .font(.system(size: 46, weight: .black, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: gameManager.isCleared ? [.pink, .purple] : [.gray, .white],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: resultColor.opacity(0.6), radius: 8)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(gameManager.isCleared ? "クリア！" : "もう一回...")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(resultColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    private var characterMessage: some View {
        Text(gameManager.isCleared
             ? gameManager.currentCharacter.clearResponse
             : gameManager.currentCharacter.wrongResponse)
            .font(.system(size: 15))
            .foregroundColor(.white.opacity(0.9))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
    }

    @ViewBuilder
    private var unlockMessage: some View {
        if gameManager.isCleared && gameManager.currentDifficulty != .hard {
            let nextChar = nextCharacterName
            Text("「\(nextChar)」が解放されました！")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.15))
                )
        }
    }

    private var actionButtons: some View {
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
                .buttonStyle(.plain)
            }

            Button(action: { gameManager.goHome() }) {
                Text("ホームに戻る")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.84))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
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
