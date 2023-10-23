import SwiftUI
import AVFoundation
import MediaPlayer

var gAudioPlayer: AudioPlayer?
var gPlayer: AVPlayer?

class AudioPlayer: ObservableObject {
    var player: AVPlayer? {
        didSet {
            if player == nil {
                print("AudioPlayer player is now nil")
            }
        }
    }

    @Published var isPlaying = false {
        didSet {
            print("AudioPlayer isPlaying: \(isPlaying)")
        }
    }

    @Published var currentProgressString: String = "00:00"
    @Published var totalDurationString: String = "00:00"
    @Published var shouldUpdateTotalDuration: Bool = true // For stoppting the update when moving the slider.
    @Published var bufferDuration: TimeInterval = 0
    @Published var bufferDurationString = ""

    var shouldUpdateTime: Bool = true
    var albumArt: String?
    var title, artist: String
    var isLive: Bool
    
    init(isLive: Bool, albumArt: String?, title: String, artist: String) {
        self.isLive = isLive
        self.albumArt = albumArt
        self.title = title
        self.artist = artist
        setupRemoteCommandCenter()
    }

    func seekToStart() {
        let targetTime = CMTime(seconds: 0, preferredTimescale: 1)
        player?.seek(to: targetTime)
    }

    private func startUpdatingTotalDuration() {
        if timeObserverToken == nil {
            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateTotalDurationString()
                if let _bufferDuration = calcBufferDuration() {
                    bufferDuration = _bufferDuration.backwardBuffer + _bufferDuration.forwardBuffer
                    bufferDurationString = timeFormatter.string(from: bufferDuration) ?? "--:--"
                }
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
            self?.forward(by: 15)
            return .success
        }
    
        commandCenter.skipBackwardCommand.preferredIntervals = [15] // Set the preferred skip interval (in seconds)
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.rewind(by: 15)
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
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }

        player?.pause()
        player = nil
        gPlayer = nil
        gAudioPlayer = nil
        currentProgressString = "00:00"
        totalDurationString = "00:00"
    }

    func getAvailableBufferSize(seconds: TimeInterval) -> TimeInterval {
        if checkMemoryAvailability(bufferSize: seconds) {
            return seconds
        }
        var seconds = seconds / 2
        if checkMemoryAvailability(bufferSize: seconds) {
            return seconds
        }
        seconds /= 2
        if checkMemoryAvailability(bufferSize: seconds) {
            return seconds
        }
        return TimeInterval(600)
    }

    func play(url: URL? = nil) {
        var isNewPlayer = false
        
        if player == nil,
           let url = url {
            isNewPlayer = true
            do {
                let asset = AVURLAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                bufferDuration = getAvailableBufferSize(seconds: 1800)
//                bufferDuration = 1800
                print("bufferDuration: \(bufferDuration)")
                item.preferredForwardBufferDuration = bufferDuration

                player = AVPlayer(playerItem: item)
                gAudioPlayer = self
                gPlayer = player
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

    func pause() {
        player?.pause()
        gPlayer?.pause()
        isPlaying = false
        updateNowPlayingInfoElapsedPlaybackTime()
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

    func seekToNewTime(_ newTime: CMTime) {
        print("seekToNewTime: \(newTime.seconds)")
        if let player = player {
           let isPlaying = isPlaying
            player.seek(to: newTime) { [weak self] _ in
                if isPlaying {
                    self?.pause()
                }
                
                self?.updateNowPlayingInfoElapsedPlaybackTime()
                self?.updateCurrentProgressString()
                                
                if isPlaying {
                    self?.play()
                }
                self?.shouldUpdateTotalDuration = true
            }
        } else {
            shouldUpdateTime = true
        }
    }

    func forward(by interval: Int) {
        if let player = player {
            let forwardTime = CMTimeMake(value: Int64(interval), timescale: 1)
            let newTime = CMTimeAdd(player.currentTime(), forwardTime)
            player.seek(to: newTime) { [weak self] _ in
                self?.updateNowPlayingInfoElapsedPlaybackTime()
                self?.updateCurrentProgressString()
                if let isPlaying = self?.isPlaying,
                   isPlaying {
                    self?.play()
                }
            }
        }
    }

    func setCurrentProgressString(time: Double) {
        currentProgressString = timeFormatter.string(from: time) ?? "00:00"
    }

    private func updateCurrentProgressString() {
        if let currentTime = player?.currentTime() {
            currentProgressString = timeFormatter.string(from: currentTime.seconds) ?? "00:00"
            print("AudioPlayer updateCurrentProgressString currentProgressString: \(currentProgressString)")
        }
    }
    
    func rewind(by interval: Int, wasPlaying: Bool? = nil) {
        if let player = player {
            let rewindTime = CMTimeMake(value: -Int64(interval), timescale: 1)
            let newTime = CMTimeAdd(player.currentTime(), rewindTime)
            player.seek(to: newTime) { [weak self] _ in
                self?.updateNowPlayingInfoElapsedPlaybackTime()
                // Update the current progress string when rewinding
                self?.updateCurrentProgressString()
                if let isPlaying = self?.isPlaying,
                   isPlaying {
                    self?.play()
                }
            }
        } else {
            print("player is nil")
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
                                if shouldUpdateTotalDuration {
                                    totalDurationString = timeFormatter.string(from: bufferedDuration) ?? "--:--"
                                    print("totalDurationString \(totalDurationString)")
                                    _ = calcBufferDuration()
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [self] in
                            if shouldUpdateTotalDuration {
                                totalDurationString = timeFormatter.string(from: duration.seconds) ?? "00:00"
                            }
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
    
    @objc func handlePlayPause() {
        // Handle the play/pause media key event
        self.isPlaying.toggle()
    }

    func calcBufferDuration() -> (backwardBuffer: Float64, forwardBuffer: Float64)? {
        if let playerItem = player?.currentItem,
           let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue {
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSeconds = CMTimeGetSeconds(timeRange.duration)
            let currentPlayheadSeconds = CMTimeGetSeconds(playerItem.currentTime())

            let bufferStart = startSeconds
            let bufferEnd = startSeconds + durationSeconds

            let backwardBuffer = currentPlayheadSeconds - bufferStart
            let forwardBuffer = bufferEnd - currentPlayheadSeconds

            print("Backward buffer: \(backwardBuffer) seconds")
            print("Forward buffer: \(forwardBuffer) seconds")

            return (backwardBuffer, forwardBuffer)
        }
        return nil
    }
}
