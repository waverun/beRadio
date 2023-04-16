import SwiftUI
import MediaPlayer
import AVFoundation

func configureNowPlayingInfo(title: String, artist: String, albumArt: UIImage? = nil, player: AVPlayer) {
    var nowPlayingInfo = [String: Any]()

    nowPlayingInfo[MPMediaItemPropertyTitle] = title
    nowPlayingInfo[MPMediaItemPropertyArtist] = artist

    if let albumArt = albumArt {
        let artwork = MPMediaItemArtwork(boundsSize: albumArt.size) { _ in
            return albumArt
        }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
    }

    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
//    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem!.asset.load(.duration)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
    
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
}
