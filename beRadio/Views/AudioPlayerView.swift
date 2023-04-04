//import SwiftUI
//import AVFoundation
//
//struct AudioPlayerView: View {
//    @ObservedObject var audioPlayer: AudioPlayer
//    private let audioUrl: URL
//
//    init(audioPlayer: AudioPlayer, url: URL) {
//        self.audioPlayer = audioPlayer
//        self.audioUrl = URL(string: "https://awaod01.streamgates.net/103fm_aw/mag0404238.mp3")!
//    }
//
////struct AudioPlayerView: View {
////    @ObservedObject private var audioPlayer: AudioPlayer
////    private let audioUrl: URL
////
////    init(url: URL) {
////        self.audioPlayer = AudioPlayer()
//////        self.audioUrl = url
////        self.audioUrl = URL(string: "https://awaod01.streamgates.net/103fm_aw/mag0404238.mp3")!
//////                                "https://awaod01.streamgates.net/103fm_aw/mag0404238.mp3?aw_0_1st.collectionid=mag&aw_0_1st.episodeid=404238&aw_0_1st.skey=1680607885&listenerid=59d2d94be9079a8d0be6c6eeced5ec01&awparams=companionAds%3Atrue&nimblesessionid=483946759")!
////    }
////
//    var body: some View {
//        HStack {
//            Text(timeString(from: audioPlayer.currentTime))
//                .foregroundColor(.white)
//
//            Button(action: {
//                audioPlayer.rewind()
//            }) {
//                Image(systemName: "backward.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 30))
//            }
//
//            Button(action: {
//                audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
//            }) {
//                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 40))
//            }
//
//            Button(action: {
//                audioPlayer.forward()
//            }) {
//                Image(systemName: "forward.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 30))
//            }
//
//            Text(timeString(from: audioPlayer.duration))
//                .foregroundColor(.white)
//        }
//    }
//
//    private func timeString(from timeInterval: TimeInterval) -> String {
//        return audioPlayer.timeFormatter.string(from: timeInterval) ?? "00:00"
//    }
//}

//import SwiftUI
//import AVFoundation
//
//struct AudioPlayerView: View {
//    @ObservedObject private var audioPlayer: AudioPlayer
//    private let audioUrl: URL
//
//    init(url: URL) {
//        self.audioPlayer = AudioPlayer()
//        self.audioUrl = url
//    }
//
//    var body: some View {
//        HStack {
//            Text("\(audioPlayer.currentTime, formatter: audioPlayer.timeFormatter)")
//                .foregroundColor(.white)
//
//            Button(action: {
//                audioPlayer.rewind()
//            }) {
//                Image(systemName: "backward.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 30))
//            }
//
//            Button(action: {
//                audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
//            }) {
//                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 40))
//            }
//
//            Button(action: {
//                audioPlayer.forward()
//            }) {
//                Image(systemName: "forward.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 30))
//            }
//
//            Text("\(audioPlayer.duration, formatter: audioPlayer.timeFormatter)")
//                .foregroundColor(.white)
//        }
//    }
//}

//import SwiftUI
//import AVFoundation
//
//struct AudioPlayerView: View {
//    @ObservedObject private var audioPlayer: AudioPlayer
//    private let audioUrl: URL
//
//    init(url: URL) {
//        self.audioPlayer = AudioPlayer()
//        self.audioUrl = url
//    }
//
//    var body: some View {
//        HStack {
//            Text("\(audioPlayer.currentTime, formatter: audioPlayer.timeFormatter)")
//                .foregroundColor(.white)
//
//            Button(action: {
//                audioPlayer.rewind()
//            }) {
//                Image(systemName: "backward.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 30))
//            }
//
//            Button(action: {
//                audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
//            }) {
//                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 40))
//            }
//
//            Button(action: {
//                audioPlayer.forward()
//            }) {
//                Image(systemName: "forward.fill")
//                    .foregroundColor(.white)
//                    .font(.system(size: 30))
//            }
//
//            Text("\(audioPlayer.duration, formatter: audioPlayer.timeFormatter)")
//                .foregroundColor(.white)
//        }
//    }
//}

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
                Button(action: {
                    audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
                }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }

                Button(action: {
                    audioPlayer.rewind()
                }) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }

                Button(action: {
                    audioPlayer.forward()
                }) {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
            }
        }
    }
}
