import SwiftUI
import AVFoundation

func configureAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try audioSession.setActive(true, options: [])
    } catch {
        print("Failed to set up audio session: \(error)")
    }
}


