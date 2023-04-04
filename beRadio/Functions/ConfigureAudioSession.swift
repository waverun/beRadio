import SwiftUI
import AVFoundation

func configureAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
    } catch {
        print("Setting category to AVAudioSessionCategoryPlayback failed.")
    }
}
