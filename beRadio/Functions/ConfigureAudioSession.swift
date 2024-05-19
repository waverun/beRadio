import SwiftUI
import AVFoundation

func configureAudioSession() {
    DispatchQueue.global(qos: .background).async {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            DispatchQueue.main.async {
                print("Error setting up audio session: \(error)")
            }
        }
    }
}
