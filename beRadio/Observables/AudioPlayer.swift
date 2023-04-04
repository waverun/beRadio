//import SwiftUI
//import AVFoundation
//
//class AudioPlayer: ObservableObject {
//    private var player: AVPlayer?
//    @Published var isPlaying = false
//
//    @Published var currentProgressString: String = "00:00"
//    @Published var totalDurationString: String = "00:00"
//
//    let timeFormatter: DateComponentsFormatter = {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.zeroFormattingBehavior = [.dropLeading, .pad]
//        return formatter
//    }()
//
//    private var timeObserverToken: Any?
//
////    func play(url: URL) {
////        player = AVPlayer(url: url)
////        player?.play()
////        isPlaying = true
////        Task {
////            await updateTotalDurationString()
////        }
////        startUpdatingCurrentProgress()
////    }
//
//    func play(url: URL) {
//        if player == nil {
//            if let timeObserverToken = timeObserverToken {
//                player?.removeTimeObserver(timeObserverToken)
//            }
//
//            player = AVPlayer(url: url)
//            Task {
//                await updateTotalDurationString()
//            }
//            startUpdatingCurrentProgress()
//        }
//
//        player?.play()
//        isPlaying = true
//    }
//
//    func pause() {
//        player?.pause()
//        isPlaying = false
//        stopUpdatingCurrentProgress()
//    }

import SwiftUI
import AVFoundation

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false

    @Published var currentProgressString: String = "00:00"
    @Published var totalDurationString: String = "00:00"
    
    init() {
//        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try audioSession.setActive(true, options: [])
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

//    // ...
//
//    private func configureAudioSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playback, mode: .default, options: [])
//            try audioSession.setActive(true, options: [])
//        } catch {
//            print("Failed to set up audio session: \(error)")
//        }
//    }

    let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.dropLeading, .pad]
        return formatter
    }()

    private var timeObserverToken: Any?
    private var isObservingTime = false

    func play(url: URL) {
        if player == nil {
            player = AVPlayer(url: url)
            Task {
                await updateTotalDurationString()
            }
        }

        if !isObservingTime {
            startUpdatingCurrentProgress()
        }

        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopUpdatingCurrentProgress()
    }

    
    // ... rest of the class code

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

    private func startUpdatingCurrentProgress() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentProgressString = self.timeFormatter.string(from: time.seconds) ?? "00:00"
        }
    }

    private func stopUpdatingCurrentProgress() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
    }

    private func updateTotalDurationString() async {
        if let currentItem = player?.currentItem {
            do {
                let duration = try await currentItem.asset.load(.duration)
                DispatchQueue.main.async { [self] in
                    totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
                }
            } catch {
                print("Error loading duration: \(error)")
            }
        }
    }
}
