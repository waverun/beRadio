import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @ObservedObject private var audioPlayer: AudioPlayer
    private let audioUrl: URL

    init(url: URL) {
        self.audioPlayer = AudioPlayer()
        self.audioUrl = url
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(audioPlayer.totalDurationString)")
                    .foregroundColor(.white)

                Button(action: {
                    audioPlayer.rewind()
                }) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }

                Button(action: {
                    audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
                }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }

                Button(action: {
                    audioPlayer.forward()
                }) {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }

                Text("\(audioPlayer.currentProgressString)")
                    .foregroundColor(.white)
            }
        }
    }
}
