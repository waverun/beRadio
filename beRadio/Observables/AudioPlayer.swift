import SwiftUI
import AVFoundation
import MediaPlayer

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false
    
    @Published var currentProgressString: String = "00:00"
    @Published var totalDurationString: String = "00:00"
    
    init() {
        setupRemoteCommandCenter()
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
            } catch {
                print("Error setting up AVPlayer: \(error)")
                return
            }
            Task {
                await updateTotalDurationString()
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
    }

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
        //        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player!.currentItem!.asset.duration.seconds
        if let currentItem = player?.currentItem {
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
                
                //                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.seconds
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
    
