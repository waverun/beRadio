import SwiftUI
import AVFoundation

//func configureAudioSession() {
//    let audioSession = AVAudioSession.sharedInstance()
//    do {
//        try audioSession.setCategory(.playback, mode: .default)
//        try audioSession.setActive(true)
//    } catch {
//        print("Setting category to AVAudioSessionCategoryPlayback failed.")
//    }
//}

//func configureAudioSession() {
//    let audioSession = AVAudioSession.sharedInstance()
//    do {
//        try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
//        try audioSession.setActive(true, options: [])
//    } catch {
//        print("Failed to set up audio session: \(error)")
//    }
//}

func configureAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setCategory(.playback, mode: .default, policy: .default, options: [.mixWithOthers])
        try audioSession.setActive(true, options: [])
    } catch {
        print("Failed to set up audio session: \(error)")
    }
}


