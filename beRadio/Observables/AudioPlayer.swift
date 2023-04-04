//import SwiftUI
//import AVFoundation
//
//class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    @Published var isPlaying = false
//    @Published var currentTime: TimeInterval = 0
//    @Published var duration: TimeInterval = 0
//
//    private var timer: Timer?
//
//    let timeFormatter: DateComponentsFormatter = {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.zeroFormattingBehavior = .pad
//        return formatter
//    }()
//
//    var player: AVAudioPlayer?
//
//    func play(url: URL) {
//        if let player = try? AVAudioPlayer(contentsOf: url) {
//            self.player = player
//            player.delegate = self
//            duration = player.duration
//            player.prepareToPlay()
//            player.play()
//            isPlaying = true
//            startUpdatingCurrentTime()
//        }
//    }
//
//    func pause() {
//        player?.pause()
//        isPlaying = false
//        stopUpdatingCurrentTime()
//    }
//
//    func forward() {
//        if let player = player {
//            let forwardTime = TimeInterval(15)
//            let newTime = player.currentTime + forwardTime
//            player.currentTime = newTime
//        }
//    }
//
//    func rewind() {
//        if let player = player {
//            let rewindTime = TimeInterval(-15)
//            let newTime = player.currentTime + rewindTime
//            player.currentTime = newTime
//        }
//    }
//
//    private func startUpdatingCurrentTime() {
//        stopUpdatingCurrentTime()
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            guard let self = self, let player = self.player else { return }
//            self.currentTime = player.currentTime
//        }
//    }
//
//    private func stopUpdatingCurrentTime() {
//        timer?.invalidate()
//        timer = nil
//    }                                                                }

import SwiftUI
import AVFoundation

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false

    func play(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func forward() {
        if let player = player {
            let forwardTime = CMTimeMake(value: 15, timescale: 1)
            let newTime = CMTimeAdd(player.currentTime(), forwardTime)
            player.seek(to: newTime)
        }
    }

    func rewind() {
        if let player = player {
            let rewindTime = CMTimeMake(value: -15, timescale: 1)
            let newTime = CMTimeAdd(player.currentTime(), rewindTime)
            player.seek(to: newTime)
        }
    }
}
