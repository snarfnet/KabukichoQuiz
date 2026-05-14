import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 0) {
            switch gameManager.gamePhase {
            case .home:
                CharacterSelectView()
            case .quiz:
                QuizView()
            }
        }
    }
}

struct CharacterSelectView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCharacter: GameCharacter?
    @State private var showGreeting = false

    var body: some View {
        ZStack {
            Image("splash_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.4)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 2) {
                        Text("私のなぞなぞ")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(.pink)
                            .shadow(color: .pink.opacity(0.8), radius: 10)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Text("解けるかなぁ！？")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(.purple)
                            .shadow(color: .purple.opacity(0.8), radius: 10)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }

                    Text("- キャラクターを選んでね -")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.76))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 104, maximum: 130), spacing: 14)], spacing: 16) {
                        ForEach(GameCharacter.allCharacters) { character in
                            CharacterCard(
                                character: character,
                                isUnlocked: gameManager.unlockedDifficulties.contains(character.difficulty),
                                isSelected: selectedCharacter?.id == character.id
                            ) {
                                if gameManager.unlockedDifficulties.contains(character.difficulty) {
                                    selectedCharacter = character
                                    showGreeting = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
                .padding(.top, 44)
                .padding(.bottom, 32)
            }

            if showGreeting, let character = selectedCharacter {
                GreetingOverlay(character: character) {
                    showGreeting = false
                    Task {
                        await gameManager.startQuiz(difficulty: character.difficulty)
                    }
                } onDismiss: {
                    showGreeting = false
                    selectedCharacter = nil
                }
            }
        }
    }
}

struct CharacterCard: View {
    let character: GameCharacter
    let isUnlocked: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Image(character.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if !isUnlocked {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.7))
                            .frame(width: 100, height: 140)

                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.pink : Color.purple.opacity(0.5),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .shadow(color: isSelected ? .pink.opacity(0.6) : .clear, radius: 8)

                Text(character.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : .gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(character.difficulty.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(difficultyColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(difficultyColor.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .disabled(!isUnlocked)
        .accessibilityIdentifier(character.name)
    }

    private var difficultyColor: Color {
        switch character.difficulty {
        case .easy: return .pink
        case .medium: return .purple
        case .hard: return .red
        }
    }
}

struct GreetingOverlay: View {
    let character: GameCharacter
    let onStart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                Image(character.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 132, height: 184)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .pink.opacity(0.5), radius: 12)

                Text(character.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text(character.greeting)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)

                Button(action: onStart) {
                    Text("クイズを始める")
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
                        .shadow(color: .pink.opacity(0.5), radius: 8)
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 30)
            .frame(maxWidth: 330)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.1, green: 0.05, blue: 0.15).opacity(0.95))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.purple.opacity(0.4), lineWidth: 1)
            )
        }
    }
}
