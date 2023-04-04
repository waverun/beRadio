import SwiftUI
import AVFoundation

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false

    @Published var currentProgressString: String = "00:00"
    @Published var totalDurationString: String = "00:00"

//    let timeFormatter: DateComponentsFormatter = {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.zeroFormattingBehavior = .pad
//        return formatter
//    }()
    
    let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.dropLeading, .pad]
        return formatter
    }()

    private var timeObserverToken: Any?

    func play(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        Task {
            await updateTotalDurationString()
        }
        startUpdatingCurrentProgress()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopUpdatingCurrentProgress()
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

//    private func updateTotalDurationString() async {
//        if let currentItem = player?.currentItem {
//            let duration = await currentItem.asset.load(.duration)
//            totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
//        }
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

//import SwiftUI
//import AVFoundation
//
//class AudioPlayer: ObservableObject {
//    private var player: AVPlayer?
//    @Published var isPlaying = false
//
//    func play(url: URL) {
//        player = AVPlayer(url: url)
//        player?.play()
//        isPlaying = true
//    }
//
//    func pause() {
//        player?.pause()
//        isPlaying = false
//    }
//
//    func forward() {
//        if let player = player {
//            let forwardTime = CMTimeMake(value: 15, timescale: 1)
//            let newTime = CMTimeAdd(player.currentTime(), forwardTime)
//            player.seek(to: newTime)
//        }
//    }
//
//    func rewind() {
//        if let player = player {
//            let rewindTime = CMTimeMake(value: -15, timescale: 1)
//            let newTime = CMTimeAdd(player.currentTime(), rewindTime)
//            player.seek(to: newTime)
//        }
//    }
//}
