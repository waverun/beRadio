import AppIntents

struct OpenCurrentlyReading: AudioStartingIntent {
    static var title: LocalizedStringResource =
    "Open Currently Reading"
    
//    @MainActora
    func perform() async throws -> some IntentResult {
        print("perform")
        DispatchQueue.main.async {
            if gAudioPlayerView != nil,
             let audioPlayer = gAudioPlayer {
                audioPlayer.rewind(by: 15)
            }
        }
        return .result ()
    }
}
