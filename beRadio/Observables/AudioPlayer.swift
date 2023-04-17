import SwiftUI
import AVFoundation
import MediaPlayer

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false
    
    @Published var currentProgressString: String = "00:00"
    @Published var totalDurationString: String = "00:00"
    
    private var isLive: Bool
    
    init(isLive: Bool) {
        self.isLive = isLive
        setupRemoteCommandCenter()
    }
            
    private func startUpdatingTotalDuration() {
        if timeObserverToken == nil {
            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateTotalDurationString()
            }
        }
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            if self?.player?.timeControlStatus == .paused {
                self?.play()
            } else {
                self?.pause()
            }
            return .success
        }
        
        commandCenter.skipForwardCommand.preferredIntervals = [15] // Set the preferred skip interval (in seconds)
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.forward()
            return .success
        }
        
        commandCenter.skipBackwardCommand.preferredIntervals = [15] // Set the preferred skip interval (in seconds)
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.rewind()
            return .success
        }
    }
    
    let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.dropLeading, .pad]
        return formatter
    }()
    
    private var timeObserverToken: Any?
    private var isObservingTime = false
    
    func resetPlayer() {
        if let oldPlayer = player {
            if let timeObserverToken = timeObserverToken {
                oldPlayer.removeTimeObserver(timeObserverToken)
                self.timeObserverToken = nil
            }
            player = nil
        }
    }
    
    func play(url: URL? = nil) {
        //        resetPlayer()
        
        if player == nil,
           let url = url {
            do {
                let asset = AVURLAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                player = AVPlayer(playerItem: item)
                try AVAudioSession.sharedInstance().setCategory(.playback)
                
                startUpdatingTotalDuration()
            } catch {
                print("Error setting up AVPlayer: \(error)")
                return
            }
        }
        
        if !isObservingTime {
            startUpdatingCurrentProgress()
        }
        
        player?.play()
        isPlaying = true
        updateNowPlayingInfoElapsedPlaybackTime()
        
        Task {
            await configureNowPlayingInfo(title: "Song Title", artist: "Artist Name", albumArt: UIImage(systemName: "antenna.radiowaves.left.and.right"))
        }
        
        if !isObservingTime {
            startUpdatingCurrentProgress()
        }
        
        stopDurationUpdateTimer()
        startUpdatingTotalDuration()
    }
    
//    func configureNowPlayingInfo(title: String, artist: String, albumArt: UIImage? = nil) async {
//        var nowPlayingInfo = [String: Any]()
//
//        nowPlayingInfo[MPMediaItemPropertyTitle] = title
//        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
//
//        if let albumArt = albumArt {
//            let artwork = MPMediaItemArtwork(boundsSize: albumArt.size) { _ in
//                return albumArt
//            }
//            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
//        }
//
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
//        if let currentItem = player?.currentItem {
//            do {
//                let duration = try await currentItem.asset.load(.duration)
//
//                if duration.timescale == 0 {
//                    if let buffer = currentItem.loadedTimeRanges.first {
//                        let timeRange = buffer.timeRangeValue
//                        let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//                        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = bufferedDuration
//                    }
//                } else {
//                    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.seconds
//                }
//
//                //                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.seconds
//            } catch {
//                print("Error loading duration: \(error)")
//            }
//        }
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
//
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
    
    func configureNowPlayingInfo(title: String, artist: String, albumArt: UIImage? = nil) async {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        
        if let albumArt = albumArt {
            let artwork = MPMediaItemArtwork(boundsSize: albumArt.size) { _ in
                return albumArt
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        
        if isLive {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = TimeInterval(Double.infinity)
        } else if let currentItem = player?.currentItem {
            do {
                let duration = try await currentItem.asset.load(.duration)
                
                if duration.timescale == 0 {
                    if let buffer = currentItem.loadedTimeRanges.first {
                        let timeRange = buffer.timeRangeValue
                        let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
                        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = bufferedDuration
                    }
                } else {
                    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.seconds
                }
                
            } catch {
                print("Error loading duration: \(error)")
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopUpdatingCurrentProgress()
        updateNowPlayingInfoElapsedPlaybackTime()
        
        startDurationUpdateTimer()
    }
    
    private var durationUpdateTimer: Timer?
        
    private func startDurationUpdateTimer() {
        if durationUpdateTimer == nil {
            durationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTotalDurationString()
            }
        }
    }
    
    private func stopDurationUpdateTimer() {
        durationUpdateTimer?.invalidate()
        durationUpdateTimer = nil
    }

    // ... rest of the class code
    
    func forward() {
        if let player = player {
            let forwardTime = CMTimeMake(value: 15, timescale: 1)
            let newTime = CMTimeAdd(player.currentTime(), forwardTime)
            player.seek(to: newTime)
            player.seek(to: newTime) { [weak self] _ in
                self?.updateNowPlayingInfoElapsedPlaybackTime()
            }
        }
    }
    
    func rewind() {
        if let player = player {
            let rewindTime = CMTimeMake(value: -15, timescale: 1)
            let newTime = CMTimeAdd(player.currentTime(), rewindTime)
            player.seek(to: newTime)
            player.seek(to: newTime) { [weak self] _ in
                self?.updateNowPlayingInfoElapsedPlaybackTime()
            }
        }
    }
    
    func updateNowPlayingInfoElapsedPlaybackTime() {
        if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
            self.timeObserverToken = nil
        }
    }
        
    private func updateTotalDurationString() {
        if let currentItem = player?.currentItem {
            let keys: [String] = ["duration"]
            currentItem.asset.loadValuesAsynchronously(forKeys: keys) {
                var error: NSError? = nil
                let status = currentItem.asset.statusOfValue(forKey: "duration", error: &error)
                
                switch status {
                case .loaded:
                    let duration = currentItem.asset.duration
                    if duration.isIndefinite {
                        // Handle the case where duration is indefinite (e.g., live streams)
                        if let buffer = currentItem.loadedTimeRanges.first {
                            let timeRange = buffer.timeRangeValue
                            let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
                            DispatchQueue.main.async { [self] in
                                totalDurationString = timeFormatter.string(from: bufferedDuration) ?? "--:--"
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [self] in
                            totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
                        }
                    }
                    
                case .failed, .cancelled:
                    print("Error loading duration: \(error?.localizedDescription ?? "Unknown error")")
                    
                default:
                    break
                }
            }
        }
    }
}
//    private func updateTotalDurationString() {
//        if let currentItem = player?.currentItem {
//            do {
//                let duration = try currentItem.asset.load(.duration)
//
//                if duration.isIndefinite {
//                    // Handle the case where duration is indefinite (e.g., live streams)
//                    if let buffer = currentItem.loadedTimeRanges.first {
//                        let timeRange = buffer.timeRangeValue
//                        let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//                        DispatchQueue.main.async { [self] in
//                            totalDurationString = timeFormatter.string(from: bufferedDuration) ?? "--:--"
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.async { [self] in
//                        totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
//                    }
//                }
//
//            } catch {
//                print("Error loading duration: \(error)")
//            }
//        }
//    }

////    private func updateTotalDurationString() async {
//    private func updateTotalDurationString() {
//        if let currentItem = player?.currentItem {
//            do {
//                let duration = try await currentItem.asset.load(.duration)
//
//                if duration.isIndefinite {
//                    // Handle the case where duration is indefinite (e.g., live streams)
//                    if let buffer = currentItem.loadedTimeRanges.first {
//                        let timeRange = buffer.timeRangeValue
//                        let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//                        DispatchQueue.main.async { [self] in
//                            totalDurationString = timeFormatter.string(from: bufferedDuration) ?? "--:--"
//                        }
//                    }
//                } else {
//                    DispatchQueue.main.async { [self] in
//                        totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
//                    }
//                }
//
//            } catch {
//                print("Error loading duration: \(error)")
//            }
//        }
//    }

//    private func updateTotalDurationString() async {
//        if let currentItem = player?.currentItem {
//            do {
//                let duration = try await currentItem.asset.load(.duration)
//
//                if duration.isIndefinite {
//                    // Handle the case where duration is indefinite (e.g., live streams)
//                    DispatchQueue.main.async { [self] in
//                        totalDurationString = "--:--"
//                    }
//                } else {
//                    DispatchQueue.main.async { [self] in
//                        totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
//                    }
//                }
//
//            } catch {
//                print("Error loading duration: \(error)")
//            }
//        }
//    }

//    func play(url: URL? = nil) {
//        if player == nil,
//           let url = url {
//            if let oldPlayer = player {
//                if let timeObserverToken = timeObserverToken {
//                    oldPlayer.removeTimeObserver(timeObserverToken)
//                }
//            }
//            player = AVPlayer(url: url)
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
//        updateNowPlayingInfoElapsedPlaybackTime()
//
//        Task {
//           await configureNowPlayingInfo(title: "Song Title", artist: "Artist Name", albumArt: UIImage(systemName: "antenna.radiowaves.left.and.right"))
//        }
//    }
    
//    import AVFoundation.AVAsyncProperty

//    private var maxCurrentProgress = 0.0

//    private var streamStartTime: Date?

//    private func updateTotalDurationString() {
//        if let currentItem = player?.currentItem {
//            let keys = ["duration"]
//            currentItem.asset.loadValuesAsynchronously(forKeys: keys) {
//                var error: NSError? = nil
//                let status = currentItem.asset.statusOfValue(forKey: "duration", error: &error)
//                switch status {
//                case .loaded:
//                    let duration = currentItem.asset.duration
//                    if duration.isIndefinite {
//                        // Handle the case where duration is indefinite (e.g., live streams)
//                        DispatchQueue.main.async { [weak self] in
//                            if let buffer = currentItem.loadedTimeRanges.first {
//                                let timeRange = buffer.timeRangeValue
//                                let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//
//                                if self?.streamStartTime == nil {
//                                    self?.streamStartTime = Date()
//                                }
//
//                                let timeElapsedSinceStart = Date().timeIntervalSince(self!.streamStartTime!)
//
//                                let currentProgress = self?.player?.currentTime().seconds ?? 0
//                                self?.maxCurrentProgress = max(self?.maxCurrentProgress ?? 0, currentProgress)
//
//                                let maxDuration = min(bufferedDuration, max(self?.maxCurrentProgress ?? 0, timeElapsedSinceStart))
//                                self?.totalDurationString = self?.timeFormatter.string(from: maxDuration) ?? "--:--"
//                            } else {
//                                self?.totalDurationString = "--:--"
//                            }
//                        }
//                    } else {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.totalDurationString = self?.timeFormatter.string(from: duration.seconds) ?? "00:00"
//                        }
//                    }
//                case .failed, .cancelled:
//                    print("Error loading duration: \(error?.localizedDescription ?? "Unknown error")")
//                default:
//                    break
//                }
//            }
//        }
//    }

//    private func updateTotalDurationString() {
//        if let currentItem = player?.currentItem {
//            let keys = ["duration"]
//            currentItem.asset.loadValuesAsynchronously(forKeys: keys) {
//                var error: NSError? = nil
//                let status = currentItem.asset.statusOfValue(forKey: "duration", error: &error)
//                switch status {
//                case .loaded:
//                    let duration = currentItem.asset.duration
//                    if duration.isIndefinite {
//                        // Handle the case where duration is indefinite (e.g., live streams)
//                        DispatchQueue.main.async { [weak self] in
//                            if let buffer = currentItem.loadedTimeRanges.first {
//                                let timeRange = buffer.timeRangeValue
//                                let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//                                let currentProgress = self?.player?.currentTime().seconds ?? 0
//                                self?.maxCurrentProgress = max(self?.maxCurrentProgress ?? 0, currentProgress)
//                                let maxDuration = min(bufferedDuration, self?.maxCurrentProgress ?? 0)
//                                self?.totalDurationString = self?.timeFormatter.string(from: maxDuration) ?? "--:--"
//                            } else {
//                                self?.totalDurationString = "--:--"
//                            }
//                        }
//                    } else {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.totalDurationString = self?.timeFormatter.string(from: duration.seconds) ?? "00:00"
//                        }
//                    }
//                case .failed, .cancelled:
//                    print("Error loading duration: \(error?.localizedDescription ?? "Unknown error")")
//                default:
//                    break
//                }
//            }
//        }
//    }

//    private func updateTotalDurationString() {
//        if let currentItem = player?.currentItem {
//            let keys = ["duration"]
//            currentItem.asset.loadValuesAsynchronously(forKeys: keys) {
//                var error: NSError? = nil
//                let status = currentItem.asset.statusOfValue(forKey: "duration", error: &error)
//                switch status {
//                case .loaded:
//                    let duration = currentItem.asset.duration
//                    if duration.isIndefinite {
//                        // Handle the case where duration is indefinite (e.g., live streams)
//                        DispatchQueue.main.async { [weak self] in
//                            if let buffer = currentItem.loadedTimeRanges.first {
//                                let timeRange = buffer.timeRangeValue
//                                let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//                                self?.totalDurationString = self?.timeFormatter.string(from: bufferedDuration) ?? "--:--"
//                            } else {
//                                self?.totalDurationString = "--:--"
//                            }
//                        }
//                    } else {
//                        DispatchQueue.main.async { [weak self] in
//                            self?.totalDurationString = self?.timeFormatter.string(from: duration.seconds) ?? "00:00"
//                        }
//                    }
//                case .failed, .cancelled:
//                    print("Error loading duration: \(error?.localizedDescription ?? "Unknown error")")
//                default:
//                    break
//                }
//            }
//        }
//    }

//    private func updateTotalDurationString() {
//        if let currentItem = player?.currentItem {
//            let keys = ["duration"]
//            currentItem.asset.loadValuesAsynchronously(forKeys: keys) {
//                var error: NSError? = nil
//                let status = currentItem.asset.statusOfValue(forKey: "duration", error: &error)
//                switch status {
//                case .loaded:
//                    let duration = currentItem.asset.duration
//                    if duration.isIndefinite {
////                    if duration.timescale == 0 {
//                        // Handle the case where duration is indefinite (e.g., live streams)
//                        DispatchQueue.main.async { [self] in
//                            totalDurationString = "--:--"
//                        }
//                    } else {
//                        DispatchQueue.main.async { [self] in
//                            totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
//                        }
//                    }
//                case .failed, .cancelled:
//                    print("Error loading duration: \(error?.localizedDescription ?? "Unknown error")")
//                default:
//                    break
//                }
//            }
//        }
//    }

//    private func startUpdatingTotalDuration() {
//        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
//            guard let self = self else { return }
//            self.updateTotalDurationString()
//        }
//    }
