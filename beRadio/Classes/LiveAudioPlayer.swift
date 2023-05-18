import SwiftUI
import AVFoundation
import MediaPlayer

class LiveAudioPlayer: ObservableObject {
//    private var player: AVPlayer?
    private var player: AVQueuePlayer?
    var streamBuffer: StreamBuffer?

    @Published var isPlaying = false

    @Published var currentProgressString: String = "00:00"
    @Published var totalDurationString: String = "00:00"
    
    init() {
//        super.init()
//        configureAudioSession()
        setupRemoteCommandCenter()
    }

    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] _ in
            self.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            self.pause()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] _ in
            if self.player!.timeControlStatus == .paused {
                self.play()
            } else {
                self.pause()
            }
            return .success
        }
    }

//    private func configureAudioSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay])
//            try audioSession.setActive(true, options: [])
//        } catch {
//            print("Failed to set up audio session: \(error)")
//        }
//    }

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

//    func play(url: URL? = nil) {
//        if player == nil,
//        let url = url {
//            player = AVPlayer(url: url)
////            player?.allowsExternalPlayback = false
//            Task {
//                await updateTotalDurationString()
//            }
//        }
//
//        if !isObservingTime {
//            startUpdatingCurrentProgress()
//        }
//
//        player?.play()
//        isPlaying = true
//    }

    func play() {
            if player == nil {
                streamBuffer = StreamBuffer(streamURL: URL(string: "https://cdn.cybercdn.live/103FM/Live/icecast.audio")!, chunkDuration: 15)
                player = AVQueuePlayer()
                startBufferingAndPlaying()
            }
            
            player?.play()
            isPlaying = true
        }
        
    private func startBufferingAndPlaying() {
        streamBuffer?.downloadChunk { [weak self] url in
            guard let self = self, let url = url else { return }
            
            let playerItem = AVPlayerItem(url: url)
            self.player?.insert(playerItem, after: nil)
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
                self.streamBuffer?.removePlayedChunk()
                self.startBufferingAndPlaying()
            }
        }
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
                
                if duration.isIndefinite {
                    // Handle the case where duration is indefinite (e.g., live streams)
                    DispatchQueue.main.async { [self] in
                        totalDurationString = "--:--"
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
                    }
                }
                
            } catch {
                print("Error loading duration: \(error)")
            }
        }
    }
}
