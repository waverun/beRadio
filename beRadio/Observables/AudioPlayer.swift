import SwiftUI
import AVFoundation
import MediaPlayer

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false
    
    @Published var currentProgressString: String = "00:00"
    @Published var totalDurationString: String = "00:00"
    
    private var shouldUpdateTime: Bool = true
    private var albumArt: String?
    private var title, artist: String
    private var isLive: Bool
    
    init(isLive: Bool, albumArt: String?, title: String, artist: String) {
        self.isLive = isLive
        self.albumArt = albumArt
        self.title = title
        self.artist = artist
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
    
    func removePlayer() {
        player = nil
        currentProgressString = "00:00"
        totalDurationString = "00:00"
    }
    
    func play(url: URL? = nil) {
        var isNewPlayer = false
        
        if player == nil,
           let url = url {
            isNewPlayer = true
            do {
                let asset = AVURLAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                player = AVPlayer(playerItem: item)
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch {
                print("Error setting up AVPlayer: \(error)")
                return
            }
        }
        
        player?.play()
        isPlaying = true
        
        if isNewPlayer {
            Task {
                await configureNowPlayingInfo(title: title, artist: artist, albumArtURL: albumArt)
            }
        }
        
        if isLive {
            stopDurationUpdateTimer()
            startUpdatingTotalDuration()
        } else {
            updateTotalDurationString()
        }

        shouldUpdateTime = true
        startUpdatingCurrentProgress()
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
    }
  
    func configureNowPlayingInfo(title: String, artist: String, albumArtURL: String? = nil) async {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        
        if let albumArtURL = albumArtURL {
            do {
                let imageData = try await downloadImageData(from: albumArtURL)
                let albumArt = imageData == nil ? UIImage(systemName: "antenna.radiowaves.left.and.right") : UIImage(data: imageData!)
                let artwork = MPMediaItemArtwork(boundsSize: albumArt!.size) { _ in
                    return albumArt!
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            } catch {
                print("Error loading album art: \(error)")
            }
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

    func downloadImageData(from urlString: String) async throws -> Data? {
        if let url = URL(string: urlString) {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
        return nil
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
//
//        if isLive {
//            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = TimeInterval(Double.infinity)
//        } else if let currentItem = player?.currentItem {
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
//            } catch {
//                print("Error loading duration: \(error)")
//            }
//        }
//
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
//
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfoElapsedPlaybackTime()
//        stopUpdatingCurrentProgress()
        shouldUpdateTime = false

        if isLive {
            startDurationUpdateTimer()
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
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
//            player.seek(to: newTime)
            player.seek(to: newTime) { [weak self] _ in
                self?.updateNowPlayingInfoElapsedPlaybackTime()
            }
        }
    }
    
    func rewind() {
        if let player = player {
            let rewindTime = CMTimeMake(value: -15, timescale: 1)
            let newTime = CMTimeAdd(player.currentTime(), rewindTime)
//            player.seek(to: newTime)
            player.seek(to: newTime) { [weak self] _ in
                self?.updateNowPlayingInfoElapsedPlaybackTime()
            }
        }
    }
    
    func updateNowPlayingInfoElapsedPlaybackTime() {
        if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo,
           let seconds = player?.currentTime().seconds {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seconds
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
        
    private func startUpdatingCurrentProgress() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            if self.shouldUpdateTime {
                self.currentProgressString = self.timeFormatter.string(from: time.seconds) ?? "00:00"
                
                if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time.seconds
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
        }
    }

    private func stopUpdatingCurrentProgress() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
        
    private func updateTotalDurationString(durationOffset: TimeInterval = 0) {
        if let currentItem = player?.currentItem {
            let keys: [String] = ["duration"]
            currentItem.asset.loadValuesAsynchronously(forKeys: keys) {
                var error: NSError? = nil
                let status = currentItem.asset.statusOfValue(forKey: "duration", error: &error)
                
                switch status {
                case .loaded:
                    let duration = currentItem.asset.duration
                    if duration.isIndefinite || duration.timescale == 0 || self.isLive {
                        // Handle the case where duration is indefinite (e.g., live streams)
                        if let buffer = currentItem.loadedTimeRanges.first {
                            let timeRange = buffer.timeRangeValue
                            let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)) + durationOffset
                            DispatchQueue.main.async { [self] in
                                totalDurationString = timeFormatter.string(from: bufferedDuration) ?? "--:--"
                                print("totalDurationString \(totalDurationString)")
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
