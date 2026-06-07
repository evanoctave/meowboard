import SwiftUI
import AVFoundation

// MARK: - Model

struct CatSound: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let filename: String
}

// MARK: - Main View

struct ContentView: View {
    private let sounds: [CatSound] = [
        CatSound(name: "Meow",  emoji: "😺", filename: "meow"),
        CatSound(name: "Purr",  emoji: "😻", filename: "purr"),
        CatSound(name: "Chirp", emoji: "🐱", filename: "chirp"),
    ]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    @State private var player: AVAudioPlayer?
    @State private var tappedID: UUID?
    @State private var showMessage = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(sounds) { sound in
                        SoundButton(
                            sound: sound,
                            isPressed: tappedID == sound.id
                        ) {
                            play(sound)
                        }
                    }
                }
                .padding()
                if showMessage {
                    Text("kitty kitty!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.top, 20)
                }
                
                Button("Say it!") {
                    withAnimation {
                        showMessage = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showMessage = false }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
            }
            .navigationTitle("🐱 Meowboard")
            .background(Color.gray.opacity(0.1))
        }
    }

    // MARK: - Playback

    private func play(_ sound: CatSound) {
        guard let url = Bundle.main.url(
            forResource: sound.filename,
            withExtension: "wav"
        ) else {
            print("⚠️ Missing sound file: \(sound.filename).wav")
            return
        }

        withAnimation { tappedID = sound.id }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation { tappedID = nil }
        }

        do {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("⚠️ Playback failed: \(error)")
        }
    }
}

// MARK: - Sound Button

struct SoundButton: View {
    let sound: CatSound
    let isPressed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(sound.emoji)
                    .font(.system(size: 48))
                Text(sound.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(.background, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.85 : 1.0)
        .animation(
            .spring(response: 0.25, dampingFraction: 0.45),
            value: isPressed
        )
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
