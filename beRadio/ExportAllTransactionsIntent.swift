import AppIntents

struct OpenCurrentlyReading: AudioStartingIntent {
    static var title: LocalizedStringResource =
    "Open Currently Reading"
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("perform")
        //        DispatchQueue.main.async {
        if let audioPlayerView = gAudioPlayerView {
            audioPlayerView.audioPlayer.rewind(by: 15)
        }
        //        }
        return .result ()
    }
}
