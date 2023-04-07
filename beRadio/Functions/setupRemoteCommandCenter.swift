//import MediaPlayer
//
//func setupRemoteCommandCenter() {
//    let commandCenter = MPRemoteCommandCenter.shared()
//    
//    commandCenter.playCommand.addTarget { [unowned self] _ in
//        self.play()
//        return .success
//    }
//    
//    commandCenter.pauseCommand.addTarget { [unowned self] _ in
//        self.pause()
//        return .success
//    }
//    
//    commandCenter.togglePlayPauseCommand.addTarget { [unowned self] _ in
//        if self.player.timeControlStatus == .paused {
//            self.play()
//        } else {
//            self.pause()
//        }
//        return .success
//    }
//}
