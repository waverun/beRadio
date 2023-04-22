//import AppIntents
//
//struct Rewind15Seconds: AudioStartingIntent {
//    static var title: LocalizedStringResource =
//    "Skip back 15 Seconds"
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("perform")
//            if gAudioPlayerView != nil,
//             let audioPlayer = gAudioPlayer {
//                if audioPlayer.player == nil {
//                    audioPlayer.player = gPlayer
//                }
//                audioPlayer.rewind(by: 30)
//            }
//        return .result ()
//    }
//}
//
//struct Rewind30Seconds: AudioStartingIntent {
//    static var title: LocalizedStringResource =
//    "Skip back 30 Seconds"
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("perform")
//            if gAudioPlayerView != nil,
//             let audioPlayer = gAudioPlayer {
//                audioPlayer.rewind(by: 30)
//            }
//        return .result ()
//    }
//}
//
//struct Rewind60Seconds: AudioStartingIntent {
//    static var title: LocalizedStringResource =
//    "Skip back 60 Seconds"
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("perform")
//            if gAudioPlayerView != nil,
//             let audioPlayer = gAudioPlayer {
//                audioPlayer.rewind(by: 60)
//            }
//        return .result ()
//    }
//}
//
//struct Rewind1Minute: AudioStartingIntent {
//    static var title: LocalizedStringResource =
//    "Skip back 1 Minute"
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("perform")
//            if gAudioPlayerView != nil,
//             let audioPlayer = gAudioPlayer {
//                audioPlayer.rewind(by: 60)
//            }
//        return .result ()
//    }
//}
//
//struct Forward15Seconds: AudioStartingIntent {
//    static var title: LocalizedStringResource =
//    "beRadio Open Currently Reading"
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("perform")
//            if gAudioPlayerView != nil,
//             let audioPlayer = gAudioPlayer {
//                audioPlayer.forward(by: 15)
//            }
//        return .result ()
//    }
//}
//
//struct Forward30Seconds: AudioStartingIntent {
//    static var title: LocalizedStringResource =
//    "Skip 30 Seconds"
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("perform")
//            if gAudioPlayerView != nil,
//             let audioPlayer = gAudioPlayer {
//                audioPlayer.forward(by: 30)
//            }
//        return .result ()
//    }
//}
//
//struct Forward60Seconds: AudioStartingIntent {
//    static var title: LocalizedStringResource =
//    "Skip 60 Seconds"
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("perform")
//            if gAudioPlayerView != nil,
//             let audioPlayer = gAudioPlayer {
//                audioPlayer.forward(by: 60)
//            }
//        return .result ()
//    }
//}
//
//struct Forward1Minute: AudioStartingIntent {
//    static var title: LocalizedStringResource =
//    "Skip 1 Minute"
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("perform")
//            if gAudioPlayerView != nil,
//             let audioPlayer = gAudioPlayer {
//                audioPlayer.forward(by: 60)
//            }
//        return .result ()
//    }
//}
